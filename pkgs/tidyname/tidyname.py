#!/usr/bin/env python3
"""tidyname - normalise filenames so structure keeps its capitals and
content does not.

Base folders are never renamed; directories keep their capitalisation at any
depth but lose spaces and punctuation; SCREAMING-CASE docs are left alone;
everything else becomes lowercase snake_case.
"""

import argparse
import json
import os
import re
import sys
import unicodedata

PLAN_HEADER = "# tidyname plan v1"

# Only a short alphanumeric tail counts as an extension, so "onlymp3.to - foo.mp3"
# keeps ".mp3" but treats the ".to" as part of the name.
EXT_RE = re.compile(r"\.[A-Za-z0-9]{1,8}$")
TAR_RE = re.compile(r"\.tar$", re.IGNORECASE)

# .hist and .th hold copyparty's index db and thumbnail cache, keyed by exact
# path; renaming anything inside them corrupts the cache.
DEFAULT_EXCLUDES = [".hist", ".th", ".git", ".svn", ".stfolder", "node_modules"]

# Structure is capitalised, content is not: base folders and the files that
# carry meaning through their capitalisation keep the name they were given.
KEEP_NAMES = [
    "readme", "readme.md", "readme.txt", "license", "license.md", "licence",
    "licence.md", "copying", "notice", "authors", "contributors", "changelog",
    "changelog.md", "contributing.md", "code_of_conduct.md", "security.md",
    "makefile", "dockerfile", "vagrantfile", "justfile", "procfile",
]

# Extensions on which an all-caps name reads as a convention doc rather than
# as a shouted content filename.
DOC_EXTS = {".md", ".txt", ".rst", ".adoc", ""}


def slug(text, lower=True):
    decomposed = unicodedata.normalize("NFKD", text)
    stripped = "".join(c for c in decomposed if not unicodedata.combining(c))
    # Surviving non-ASCII becomes a separator rather than vanishing, so the word
    # boundary in "über—dash" is kept instead of yielding "uberdash".
    ascii_only = "".join(c if ord(c) < 128 else " " for c in stripped)
    if lower:
        ascii_only = ascii_only.lower()
    return re.sub(r"[^A-Za-z0-9]+", "_", ascii_only).strip("_")


def split_ext(name):
    match = EXT_RE.search(name)
    if not match or not name[: match.start()].strip("."):
        return name, ""
    stem, ext = name[: match.start()], match.group(0)
    tar = TAR_RE.search(stem)
    if tar and stem[: tar.start()].strip("."):
        return stem[: tar.start()], ".tar" + ext
    return stem, ext


def normalize(name, lower=True):
    """Returns (new_name, lossy) where lossy means the stem had no ASCII to keep."""
    if name in (".", ".."):
        return name, False
    dot = "." if name.startswith(".") else ""
    stem, ext = split_ext(name[1:] if dot else name)
    body = slug(stem, lower)
    lossy = not body
    if lossy:
        body = "unnamed"
    ext = re.sub(r"[^A-Za-z0-9.]+", "", ext.lower() if lower else ext)
    return dot + body + ext, lossy


def dedupe(candidate, taken):
    if candidate not in taken:
        return candidate
    dot = "." if candidate.startswith(".") else ""
    stem, ext = split_ext(candidate[1:] if dot else candidate)
    for n in range(2, 10000):
        alt = "%s%s_%d%s" % (dot, stem, n, ext)
        if alt not in taken:
            return alt
    raise RuntimeError("could not find a free name for %r" % candidate)


def walk(root, excludes):
    """Yields (dirpath, entries, at_root); entries are (name, is_dir) pairs."""
    root = os.path.abspath(root)
    for dirpath, dirnames, filenames in os.walk(root, topdown=True):
        dirnames[:] = sorted(d for d in dirnames if d not in excludes)
        files = sorted(f for f in filenames if f not in excludes)
        entries = [(d, True) for d in dirnames] + [(f, False) for f in files]
        yield dirpath, entries, dirpath == root


def is_convention_doc(name):
    """SCREAMING-CASE docs (README.md, AGENTS.md, LICENSE) name themselves by
    their capitalisation, so lowercasing them would destroy the signal."""
    stem, ext = os.path.splitext(name)
    return (
        ext.lower() in DOC_EXTS
        and re.search(r"[A-Z]", stem)
        and not re.search(r"[a-z]", stem)
    )


def keeps(name, is_dir, at_root, keep_names, keep_roots, dir_case):
    if name.lower() in keep_names:
        return True
    if is_dir and (dir_case == "keep" or (keep_roots and at_root)):
        return True
    return not is_dir and is_convention_doc(name)


def build_plan(root, excludes, keep_names, keep_roots, dir_case):
    renames = []
    lossy = []
    skipped = []
    for dirpath, entries, at_root in walk(root, excludes):
        # Every current entry is reserved, not just the ones staying put: that
        # way a rename can never land on a name the apply pass has not freed yet.
        taken = set(n for n, _ in entries)
        for name, is_dir in entries:
            if keeps(name, is_dir, at_root, keep_names, keep_roots, dir_case):
                continue
            if "\n" in name or "\r" in name:
                skipped.append(os.path.join(dirpath, name))
                continue
            new, is_lossy = normalize(name, lower=not (is_dir and dir_case == "preserve"))
            if new == name:
                continue
            new = dedupe(new, taken)
            taken.add(new)
            src = os.path.join(dirpath, name)
            renames.append((os.path.relpath(src, root), os.path.relpath(os.path.join(dirpath, new), root)))
            if is_lossy:
                lossy.append(os.path.relpath(src, root))
    return renames, lossy, skipped


def write_plan(path, root, renames, lossy, skipped):
    lossy = set(lossy)
    out = [
        PLAN_HEADER,
        "# root: %s" % os.path.abspath(root),
        "# %d renames" % len(renames),
        "#",
        "# Comment out ('#') or delete a -/+ pair to skip that rename.",
        "# Edit a '+' line to choose a different name.",
    ]
    if skipped:
        out.append("#")
        out.append("# %d entries skipped (newline in filename, rename by hand):" % len(skipped))
        out += ["#   %s" % s.replace("\n", "\\n").replace("\r", "\\r") for s in skipped]
    out.append("")
    for src, dst in renames:
        if src in lossy:
            out.append("# LOSSY: nothing ASCII survived in the original name, review this one")
        out.append("- %s" % src)
        out.append("+ %s" % dst)
        out.append("")
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(out))


def read_plan(path):
    root = None
    pairs = []
    pending = None
    with open(path, encoding="utf-8") as fh:
        for lineno, raw in enumerate(fh, 1):
            line = raw.rstrip("\n")
            if line.startswith("# root: "):
                root = line[len("# root: ") :].strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("- "):
                if pending is not None:
                    die("plan line %d: '- %s' has no matching '+' line" % (lineno, pending))
                pending = line[2:]
            elif line.startswith("+ "):
                if pending is None:
                    die("plan line %d: '+' line with no preceding '-' line" % lineno)
                pairs.append((pending, line[2:]))
                pending = None
            else:
                die("plan line %d: expected '-', '+' or '#', got %r" % (lineno, line[:40]))
    if pending is not None:
        die("plan ends with an unmatched '- %s'" % pending)
    if not root:
        die("plan is missing its '# root:' header")
    return root, pairs


def apply_plan(root, pairs, undo_path, dry_run):
    # Deepest first, so renaming a directory never invalidates the paths of the
    # children still queued underneath it.
    pairs = sorted(pairs, key=lambda p: p[0].count(os.sep), reverse=True)
    done = failed = 0
    undo = None if dry_run else open(undo_path, "a", encoding="utf-8")
    try:
        for src, dst in pairs:
            abs_src = os.path.join(root, src)
            abs_dst = os.path.join(root, dst)
            if not os.path.lexists(abs_src):
                warn("gone, skipping: %s" % src)
                failed += 1
                continue
            if os.path.lexists(abs_dst):
                warn("target exists, skipping: %s -> %s" % (src, dst))
                failed += 1
                continue
            if dry_run:
                print("%s -> %s" % (src, dst))
                done += 1
                continue
            try:
                os.rename(abs_src, abs_dst)
            except OSError as e:
                warn("failed: %s -> %s (%s)" % (src, dst, e))
                failed += 1
                continue
            undo.write(json.dumps({"root": root, "from": src, "to": dst}) + "\n")
            undo.flush()
            done += 1
    finally:
        if undo:
            undo.close()
    return done, failed


def cmd_plan(args):
    if not os.path.isdir(args.directory):
        die("not a directory: %s" % args.directory)
    renames, lossy, skipped = build_plan(
        args.directory, set(args.exclude), scan_keeps(args), args.keep_roots, args.dir_case)
    if not renames:
        print("nothing to rename under %s" % args.directory)
        return 0
    write_plan(args.output, args.directory, renames, lossy, skipped)
    print("wrote %d renames to %s" % (len(renames), args.output))
    if lossy:
        print("%d marked LOSSY - review those before applying" % len(lossy))
    if skipped:
        print("%d skipped (newline in filename)" % len(skipped))
    return 0


def cmd_apply(args):
    root, pairs = read_plan(args.plan)
    if not pairs:
        print("plan has no renames left")
        return 0
    if not os.path.isdir(root):
        die("plan root no longer exists: %s" % root)
    done, failed = apply_plan(root, pairs, args.undo_log, args.dry_run)
    if args.dry_run:
        print("would rename %d, %d unapplicable" % (done, failed))
    else:
        print("renamed %d, %d failed" % (done, failed))
        if done:
            print("undo log: %s" % args.undo_log)
    return 1 if failed else 0


def cmd_undo(args):
    entries = []
    with open(args.undo_log, encoding="utf-8") as fh:
        for line in fh:
            if line.strip():
                entries.append(json.loads(line))
    done = failed = 0
    for e in reversed(entries):
        abs_now = os.path.join(e["root"], e["to"])
        abs_was = os.path.join(e["root"], e["from"])
        if not os.path.lexists(abs_now):
            warn("gone, skipping: %s" % e["to"])
            failed += 1
            continue
        if os.path.lexists(abs_was):
            warn("original path occupied, skipping: %s" % e["from"])
            failed += 1
            continue
        if args.dry_run:
            print("%s -> %s" % (e["to"], e["from"]))
            done += 1
            continue
        try:
            os.rename(abs_now, abs_was)
            done += 1
        except OSError as err:
            warn("failed: %s (%s)" % (e["to"], err))
            failed += 1
    print("%s %d, %d failed" % ("would revert" if args.dry_run else "reverted", done, failed))
    return 1 if failed else 0


def cmd_check(args):
    if not os.path.isdir(args.directory):
        die("not a directory: %s" % args.directory)
    renames, _, skipped = build_plan(
        args.directory, set(args.exclude), scan_keeps(args), args.keep_roots, args.dir_case)
    for src, dst in renames:
        print("%s -> %s" % (src, dst))
    for s in skipped:
        print("%s (newline in filename)" % s.replace("\n", "\\n"))
    bad = len(renames) + len(skipped)
    if bad and not args.quiet:
        warn("%d of the paths under %s do not conform" % (bad, args.directory))
    return 1 if bad else 0


def cmd_name(args):
    for name in args.names:
        print(normalize(name)[0])
    return 0


def cmd_hook(args):
    """copyparty --xbu j,c1 hook: rename incoming uploads on arrival."""
    try:
        info = json.loads(args.json)
        old = os.path.basename(info["vp"])
        new = old if old.lower() in set(KEEP_NAMES) else normalize(old)[0]
        # copyparty resolves its own collisions, so only speak up on a real change.
        print(json.dumps({"reloc": {"fn": new}} if new != old else {}))
    except Exception as e:
        # Never block an upload because the hook tripped over something.
        warn("tidyname hook: %s" % e)
        print("{}")
    return 0


def scan_keeps(args):
    return set(n.lower() for n in args.keep)


def warn(msg):
    sys.stderr.write("tidyname: %s\n" % msg)


def die(msg):
    warn(msg)
    sys.exit(2)


def main():
    ap = argparse.ArgumentParser(prog="tidyname", description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)

    def with_scan_opts(p):
        p.add_argument("-x", "--exclude", action="append", default=list(DEFAULT_EXCLUDES),
                       metavar="NAME", help="directory/file name to skip (repeatable)")
        p.add_argument("-k", "--keep", action="append", default=list(KEEP_NAMES),
                       metavar="NAME", help="name to leave capitalised (repeatable)")
        p.add_argument("--rename-roots", dest="keep_roots", action="store_false",
                       help="also rename the base folders (kept by default)")
        p.add_argument("--dir-case", choices=["preserve", "lower", "keep"], default="preserve",
                       help="directories: keep their capitals but still drop spaces "
                            "(preserve, default), lowercase them too (lower), or "
                            "do not touch them at all (keep)")
        return p

    p = with_scan_opts(sub.add_parser("plan", help="write a reviewable rename plan"))
    p.add_argument("directory")
    p.add_argument("-o", "--output", default="tidyname.plan")
    p.set_defaults(func=cmd_plan)

    p = sub.add_parser("apply", help="execute a reviewed plan")
    p.add_argument("plan")
    p.add_argument("-u", "--undo-log", default="tidyname.undo.jsonl")
    p.add_argument("-n", "--dry-run", action="store_true")
    p.set_defaults(func=cmd_apply)

    p = sub.add_parser("undo", help="reverse an applied plan")
    p.add_argument("undo_log")
    p.add_argument("-n", "--dry-run", action="store_true")
    p.set_defaults(func=cmd_undo)

    p = with_scan_opts(sub.add_parser("check", help="list non-conforming paths; exit 1 if any"))
    p.add_argument("directory")
    p.add_argument("-q", "--quiet", action="store_true")
    p.set_defaults(func=cmd_check)

    p = sub.add_parser("name", help="print the normalised form of each argument")
    p.add_argument("names", nargs="+")
    p.set_defaults(func=cmd_name)

    p = sub.add_parser("hook", help="copyparty --xbu j,c1 upload hook")
    p.add_argument("json", nargs="?")
    p.set_defaults(func=cmd_hook)

    args = ap.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
