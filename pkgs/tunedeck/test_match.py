#!/usr/bin/env python3
"""Regression tests for tunedeck's track matcher.

The matcher is the only part with interesting logic, and a wrong match is the
failure mode that actually hurts: it silently puts a cover, a live cut, or an
unrelated song into a playlist, or mirrors the wrong track to Spotify.

Run with the same interpreter the package uses:
    nix build -f package.nix && ./result/bin/tunedeck --help   # deps
    python3 pkgs/tunedeck/test_match.py
"""

import importlib.util
import os
import sys
from pathlib import Path

os.environ.setdefault("NAVIDROME_USER", "test")
os.environ.setdefault("NAVIDROME_PASSWORD", "test")

spec = importlib.util.spec_from_file_location("tunedeck", Path(__file__).with_name("tunedeck.py"))
td = importlib.util.module_from_spec(spec)
spec.loader.exec_module(td)

# local title, local artist, local secs, spotify title, spotify artist, spotify secs, should match
CASES = [
    ("Bohemian Rhapsody", "Queen", 355, "Bohemian Rhapsody - Remastered 2011", "Queen", 355, True),
    ("Sicko Mode", "Travis Scott", 312, "SICKO MODE", "Travis Scott, Drake", 312, True),
    ("Runaway", "Kanye West", 548, "Runaway (feat. Pusha T)", "Kanye West", 550, True),
    ("Weightless", "Marconi Union", 480, "Weightless", "Marconi Union", 0, True),
    # same title, different artist: a cover, never our track
    ("Creep", "Radiohead", 238, "Creep", "TLC", 240, False),
    ("Redbone", "Childish Gambino", 326, "Redbone", "Donald Glover", 326, False),
    # near-miss titles must not match on artist alone
    ("Creep", "Radiohead", 238, "Creepin'", "Metro Boomin", 221, False),
    # exact title + artist survives a wildly different duration (live cut)
    ("Alright", "Kendrick Lamar", 219, "Alright", "Kendrick Lamar", 340, True),
]


def main() -> int:
    failures = 0
    for l_title, l_artist, l_secs, s_title, s_artist, s_secs, want in CASES:
        got = td.score(l_title, l_artist, l_secs, s_title, s_artist, s_secs)
        ok = (got >= 0.6) == want
        failures += not ok
        print(f"{'ok  ' if ok else 'FAIL'} {got:.2f}  {l_artist} — {l_title}  vs  {s_artist} — {s_title}")

    assert td.norm("Bohemian Rhapsody - Remastered 2011") == "bohemianrhapsody"
    assert td.norm("Runaway (feat. Pusha T)") == "runaway"
    assert td.primary_artist("Travis Scott, Drake") == "Travis Scott"
    assert td.safe_filename("[sp] Discover Weekly / 2026") == "[sp] Discover Weekly _ 2026"

    print("\n" + ("all matcher cases pass" if not failures else f"{failures} case(s) failed"))
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
