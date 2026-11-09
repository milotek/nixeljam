```markdown
# Milo's opinions

My standing defaults on tech, tools, and how software should be built.
Read this before making a technical call with more than one reasonable answer, so decisions stay consistent across repos.

## How to use this file

- Local repo conventions come first (see `AGENTS.md`).
  Use this file for greenfield work or open choices.
- If a section covers the decision, follow it.
  If this specific problem genuinely argues for something else, make that case out loud instead of quietly ignoring the default.
- If a recurring choice isn't covered here, ask me, then write the general rule back into this file.
- Do not log one-offs.
  Decisions that only matter to a single project belong in that repo, not here.
- Delete anything that goes stale.

---

## Taste and defaults

- Simplicity is king across code, architecture, and UI.
  Less is more, and less code is best code.
- Do not spam comments explaining obvious code.
  Only write a comment to explain why, or when something looks wrong at first glance and a reader would otherwise try to "fix" it.
- Do it properly the first time.
  Cutting corners when there's no hard deadline just leaves a mess for future me.
- Care about aesthetics.
  Anything I look at all day deserves real attention to theming, typography, and pixel-level polish, and looking better is a valid reason to pick one tool over another.
- Snap dimensions, spacing, and controls to clean increments (4px/8px grids, powers of two, 15/30/45 degrees, steps of 5) rather than arbitrary off-grid values like 96.7273 or 37.
- Reach for existing libraries, icon sets, and upstream defaults before rolling your own.
  Every custom helper or hand-drawn SVG is something I now have to maintain myself.
- New and shiny tools are fine when they're genuinely better (Ghostty, Hyprland, Zellij), as long as they have real bus factor and won't die if one maintainer burns out.
- Keep shared config and constants in one place instead of repeating them across modules, and delete duplication before building an abstraction to keep copies in sync.
- Name interfaces and modules after what they do rather than which library or provider backs them, so swapping the implementation later only touches one place.

## Languages and packages

- Python is my default for backend services and any script with real logic.
  Manage packages with `uv` (inside a Nix devshell when using Nix, since `nixpkgs` lags on Python libraries).
- Bash is fine for quick, finite scripts I run myself.
  Once something gets shared, runs on a schedule, or grows real control flow, write it in Python.
- Use TypeScript on Node on the backend only when client and server need to share code directly, like multiplayer simulation or shared validation.
- Stick to `npm` over `pnpm` or `bun`.
  It ships with Node and works out of the box with `buildNpmPackage` in Nix.

## Web and UI

- Default to server-rendered HTML with minimal JS until client state genuinely justifies a frontend build.
  Having no framework churn to migrate in two years is a feature.
- Use Flask over FastAPI or Django for Python web apps.
  It routes requests and stays out of the way without dictating how the app is structured.
- Use a static site generator like Astro for blogs and docs sites instead of hand-rolling markdown parsing and routing.
  For a handful of static pages with no blog, plain HTML or a tiny script is fine.
- When browser TypeScript is needed, build with Vite and test with Vitest so dev, prod, and tests share one pipeline.
- Use `three.js` for browser 3D over full engines like Babylon.js, so rendering composes cleanly with plain DOM UI and whatever physics or netcode the project owns.

## Data and storage

- Postgres is my default database.
  Only stick with SQLite when an upstream app already ships with it.
- Where a language or repo doesn't already dictate file naming (like assets, media, and stored files), use `lowercase_snake_case` with no spaces or punctuation, and normalise filenames on arrival rather than sweeping them up later.
  Keep capitalisation on folder names and standard docs (`README.md`, `AGENTS.md`, `LICENSE`) so directory structure stands out from content.
- Back up irreplaceable data (photos, notes, vaults, media), and skip backing up service state that can be rebuilt from config.
- Before running a bulk rename, migration, or data cleanup, emit a dry-run plan to review (never stage work by mutating records in place), and write an undo log so changes can be rolled back.

## Infra and self-hosting

- Self-host by default when the data is already mine.
  Only pay for hosted services when the catalogue is the product (like Spotify) or running the hardware/storage costs more than the subscription.
- Put public ingress on a cheap VPS with a real public IP instead of Cloudflare Tunnel, which caps request bodies, limits you to HTTP, and terminates TLS on someone else's box.
- Keep all private access on Tailscale: SSH, admin panels, and host-to-host links stay on the tailnet.
  Never expose public SSH ports, public admin UIs, or hand-rolled `ssh -R` tunnel loops.
- Encrypt actual secrets (keys, tokens, passwords) with `sops`, and leave hostnames, domains, ports, and topology in plaintext so configs stay readable.
- Separate reusable infra/module config from personal content and state, and avoid hardcoding modules around one machine's quirks.
- On NixOS: prefer native `nixpkgs` modules over containers (only containerise when native packaging isn't worth the pain), add explicit `systemd` hardening (`ProtectSystem`, `NoNewPrivileges`, etc.) to hand-written units, pull broken packages from `unstable` before writing overlays, and bump flake inputs often so breakages stay easy to bisect.
- Skip heavy monitoring stacks (Prometheus, Grafana) on personal infra.
  An `OnFailure=` push notification is plenty for jobs that might fail silently.

## Workflow and verification

- Keep commits small and independently revertible on a linear history (rebase over merge; straight to `main` for small verified changes, branch and PR for risky work).
- Commit messages explain why; the diff already shows what.
- Only write standalone docs for what the code can't say itself: decisions, migrations, and manual procedures.
- Prefer running and testing the real thing end-to-end over unit tests full of mocks on glue code.
- Never report something as working unless you actually ran it, and still read the diff carefully - passing tests don't catch code that solves the wrong problem.
```