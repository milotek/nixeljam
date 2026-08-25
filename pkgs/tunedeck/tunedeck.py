#!/usr/bin/env python3
"""tunedeck — glue between a self-hosted Navidrome library and Spotify/SoundCloud.

Three jobs, three subcommands:

  auth    one-off OAuth handshake, caches a refresh token in the state dir
  mirror  long-running: whatever Navidrome is playing, play it on Spotify too
  sync    one-shot: reconcile playlists in both directions, pull SoundCloud

Everything is configured through environment variables (see CONFIG below), which
the NixOS modules render from sops secrets. Nothing here reads a config file.
"""

from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import os
import random
import re
import string
import subprocess
import sys
import time
import unicodedata
from pathlib import Path
from typing import Any, Iterable

import requests
import spotipy
from spotipy.oauth2 import SpotifyOAuth

# ---------------------------------------------------------------------------
# config
# ---------------------------------------------------------------------------

STATE = Path(os.environ.get("TUNEDECK_STATE", "/var/lib/tunedeck"))

NAVIDROME_URL = os.environ.get("NAVIDROME_URL", "http://127.0.0.1:4533").rstrip("/")
NAVIDROME_USER = os.environ.get("NAVIDROME_USER", "")
NAVIDROME_PASSWORD = os.environ.get("NAVIDROME_PASSWORD", "")

MUSIC_DIR = Path(os.environ.get("MUSIC_DIR", "/var/lib/copyparty/Music"))
PLAYLIST_DIR = Path(os.environ.get("PLAYLIST_DIR", str(MUSIC_DIR / "Playlists")))
DOWNLOAD_DIR = Path(os.environ.get("DOWNLOAD_DIR", str(MUSIC_DIR / "Songs" / "Tunedeck")))

SPOTIFY_CLIENT_ID = os.environ.get("SPOTIFY_CLIENT_ID", "")
SPOTIFY_CLIENT_SECRET = os.environ.get("SPOTIFY_CLIENT_SECRET", "")
SPOTIFY_REDIRECT_URI = os.environ.get("SPOTIFY_REDIRECT_URI", "http://127.0.0.1:8974/callback")

# Playlists we pushed up carry PUSH_PREFIX; playlists we pulled down carry
# PULL_PREFIX. Each direction skips the other's prefix, which is the whole
# loop-prevention scheme. Keep them distinct and non-empty.
PULL_PREFIX = os.environ.get("PULL_PREFIX", "[sp] ")
PUSH_PREFIX = os.environ.get("PUSH_PREFIX", "[nd] ")

SYNC_LIKED = os.environ.get("SYNC_LIKED", "1") == "1"
AUTO_DOWNLOAD = os.environ.get("AUTO_DOWNLOAD", "1") == "1"
SPOTDL_BIN = os.environ.get("SPOTDL_BIN", "spotdl")
SCDL_BIN = os.environ.get("SCDL_BIN", "scdl")
SOUNDCLOUD_URLS = [u for u in os.environ.get("SOUNDCLOUD_URLS", "").split(",") if u.strip()]

MIRROR_DEVICE = os.environ.get("MIRROR_DEVICE", "tunedeck")
MIRROR_POLL_SECONDS = int(os.environ.get("MIRROR_POLL_SECONDS", "10"))
MIRROR_DAILY_LIMIT_MINUTES = int(os.environ.get("MIRROR_DAILY_LIMIT_MINUTES", "240"))
MIRROR_MIN_TRACK_SECONDS = int(os.environ.get("MIRROR_MIN_TRACK_SECONDS", "35"))
DBUS_DEST = os.environ.get("DBUS_DEST", "org.mpris.MediaPlayer2.spotify")

USER_AGENT = "tunedeck/1.0"


def log(*parts: Any) -> None:
    stamp = dt.datetime.now().strftime("%H:%M:%S")
    print(stamp, *parts, flush=True)


def die(msg: str) -> "NoReturn":  # type: ignore[valid-type]
    print(f"tunedeck: {msg}", file=sys.stderr)
    raise SystemExit(1)


# ---------------------------------------------------------------------------
# json state helpers — small files in STATE, written atomically
# ---------------------------------------------------------------------------


def load_state(name: str, default: Any) -> Any:
    path = STATE / name
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError):
        return default


def save_state(name: str, value: Any) -> None:
    STATE.mkdir(parents=True, exist_ok=True)
    path = STATE / name
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_text(json.dumps(value, indent=2, sort_keys=True))
    tmp.replace(path)


# ---------------------------------------------------------------------------
# subsonic / navidrome
# ---------------------------------------------------------------------------


class Navidrome:
    """Minimal Subsonic REST client. Token auth (salt + md5), never plaintext."""

    def __init__(self) -> None:
        if not NAVIDROME_USER or not NAVIDROME_PASSWORD:
            die("NAVIDROME_USER / NAVIDROME_PASSWORD are unset")
        self.session = requests.Session()
        self.session.headers["User-Agent"] = USER_AGENT

    def _auth(self) -> dict[str, str]:
        salt = "".join(random.choices(string.ascii_lowercase + string.digits, k=12))
        token = hashlib.md5((NAVIDROME_PASSWORD + salt).encode()).hexdigest()
        return {
            "u": NAVIDROME_USER,
            "t": token,
            "s": salt,
            "v": "1.16.1",
            "c": "tunedeck",
            "f": "json",
        }

    def call(self, endpoint: str, **params: Any) -> dict[str, Any]:
        url = f"{NAVIDROME_URL}/rest/{endpoint}"
        merged = {**self._auth(), **{k: v for k, v in params.items() if v is not None}}
        resp = self.session.get(url, params=merged, timeout=30)
        resp.raise_for_status()
        body = resp.json().get("subsonic-response", {})
        if body.get("status") != "ok":
            err = body.get("error", {})
            raise RuntimeError(f"{endpoint}: {err.get('message', 'unknown error')}")
        return body

    # -- reads we actually use ------------------------------------------------

    def now_playing(self) -> list[dict[str, Any]]:
        entries = self.call("getNowPlaying").get("nowPlaying", {}).get("entry", [])
        return entries if isinstance(entries, list) else [entries]

    def playlists(self) -> list[dict[str, Any]]:
        got = self.call("getPlaylists").get("playlists", {}).get("playlist", [])
        return got if isinstance(got, list) else [got]

    def playlist(self, pid: str) -> list[dict[str, Any]]:
        entries = self.call("getPlaylist", id=pid).get("playlist", {}).get("entry", [])
        return entries if isinstance(entries, list) else [entries]

    def search_song(self, query: str, count: int = 20) -> list[dict[str, Any]]:
        got = self.call(
            "search3", query=query, songCount=count, albumCount=0, artistCount=0
        ).get("searchResult3", {}).get("song", [])
        return got if isinstance(got, list) else [got]

    def scan_now(self) -> None:
        """Nudge the scanner so freshly written m3u/audio show up without waiting."""
        try:
            self.call("startScan")
        except Exception as exc:  # scanning is best-effort, never fatal
            log("scan trigger failed:", exc)


# ---------------------------------------------------------------------------
# fuzzy matching — shared by every direction
# ---------------------------------------------------------------------------

_PAREN = re.compile(r"\s*[\(\[][^)\]]*[\)\]]")
_FEAT = re.compile(r"\s*(feat\.?|ft\.?|featuring|with)\s+.*$", re.I)
_NOISE = re.compile(r"[^a-z0-9]+")
# Suffixes that mean "same song, different packaging" — dropping them helps a
# local rip match a Spotify release and vice versa.
_EDITION = re.compile(
    r"\s*-\s*(remaster(ed)?|\d{4} remaster(ed)?|radio edit|single version|"
    r"album version|mono|stereo|bonus track|deluxe|explicit)\b.*$",
    re.I,
)


def norm(text: str | None) -> str:
    if not text:
        return ""
    text = unicodedata.normalize("NFKD", text)
    text = "".join(c for c in text if not unicodedata.combining(c))
    text = text.lower()
    text = _EDITION.sub("", text)
    text = _PAREN.sub("", text)
    text = _FEAT.sub("", text)
    return _NOISE.sub("", text)


def primary_artist(artist: str | None) -> str:
    """'A feat. B', 'A & B', 'A, B' -> 'A'. Credit lists differ per platform."""
    if not artist:
        return ""
    return re.split(r"\s*(?:,|&|feat\.?|ft\.?|featuring|x|vs\.?)\s+", artist, flags=re.I)[0]


def score(a_title: str, a_artist: str, a_secs: int, b_title: str, b_artist: str, b_secs: int) -> float:
    """0..1, where >=0.6 means "the same song" in practice.

    Title and artist are hard gates, not weights: a shared title across two
    different artists is a cover or a coincidence, and letting a close duration
    drag that over the line produced exactly the wrong matches in testing.
    Duration only breaks ties between loose title matches.
    """
    t_a, t_b = norm(a_title), norm(b_title)
    if not t_a or not t_b:
        return 0.0
    if t_a == t_b:
        title = 1.0
    elif t_a in t_b or t_b in t_a:
        title = 0.75
    else:
        return 0.0  # different song; nothing else can rescue it

    ar_a, ar_b = norm(primary_artist(a_artist)), norm(primary_artist(b_artist))
    if ar_a and ar_b:
        related = ar_a == ar_b or ar_a in ar_b or ar_b in ar_a
        if not related and norm(a_artist) != norm(b_artist):
            return 0.0  # same title, different artist — a cover, not our track

    if a_secs and b_secs:
        delta = abs(a_secs - b_secs)
        duration = 1.0 if delta <= 5 else 0.6 if delta <= 15 else 0.0
    else:
        duration = 0.5  # unknown duration should not veto an otherwise good match

    return 0.75 * title + 0.25 * duration



# ---------------------------------------------------------------------------
# spotify
# ---------------------------------------------------------------------------

# Read-only playback scopes plus playlist write. Deliberately NOT requesting
# user-modify-playback-state: the Web API's playback control is Premium-only, so
# the mirror drives the desktop client over MPRIS instead. Everything here works
# on a free account.
SCOPES = " ".join(
    [
        "user-read-playback-state",
        "user-read-currently-playing",
        "user-read-recently-played",
        "user-library-read",
        "playlist-read-private",
        "playlist-read-collaborative",
        "playlist-modify-private",
        "playlist-modify-public",
    ]
)


def spotify(open_browser: bool = False) -> spotipy.Spotify:
    if not SPOTIFY_CLIENT_ID or not SPOTIFY_CLIENT_SECRET:
        die("SPOTIFY_CLIENT_ID / SPOTIFY_CLIENT_SECRET are unset")
    STATE.mkdir(parents=True, exist_ok=True)
    auth = SpotifyOAuth(
        client_id=SPOTIFY_CLIENT_ID,
        client_secret=SPOTIFY_CLIENT_SECRET,
        redirect_uri=SPOTIFY_REDIRECT_URI,
        scope=SCOPES,
        cache_path=str(STATE / "spotify-token.json"),
        open_browser=open_browser,
    )
    return spotipy.Spotify(auth_manager=auth, requests_timeout=30, retries=3)


class Matcher:
    """Navidrome track -> Spotify track id, with a persistent two-sided cache.

    Negative results are cached too (as null): without that, every sync run
    re-searches the same handful of tracks Spotify simply does not have.
    """

    def __init__(self, sp: spotipy.Spotify) -> None:
        self.sp = sp
        self.cache: dict[str, str | None] = load_state("match-cache.json", {})
        self.dirty = False

    def flush(self) -> None:
        if self.dirty:
            save_state("match-cache.json", self.cache)
            self.dirty = False

    def find(self, title: str, artist: str, secs: int = 0) -> str | None:
        key = f"{norm(artist)}|||{norm(title)}"
        if key in self.cache:
            return self.cache[key]

        best: tuple[float, str | None] = (0.0, None)
        queries = [
            f'track:"{title}" artist:"{primary_artist(artist)}"',
            f"{artist} {title}",
            f"{primary_artist(artist)} {_PAREN.sub('', title)}",
        ]
        for query in queries:
            try:
                items = self.sp.search(q=query, type="track", limit=10)["tracks"]["items"]
            except Exception as exc:
                log("spotify search failed:", exc)
                return None
            for item in items:
                cand = score(
                    title,
                    artist,
                    secs,
                    item["name"],
                    ", ".join(a["name"] for a in item["artists"]),
                    round(item["duration_ms"] / 1000),
                )
                if cand > best[0]:
                    best = (cand, item["id"])
            if best[0] >= 0.9:
                break  # confident enough, stop burning API calls

        found = best[1] if best[0] >= 0.6 else None
        self.cache[key] = found
        self.dirty = True
        return found


# ---------------------------------------------------------------------------
# mirror — replay Navidrome's now-playing on the headless Spotify client
# ---------------------------------------------------------------------------


def mpris(method: str, *args: str) -> bool:
    cmd = [
        "dbus-send",
        "--session",
        f"--dest={DBUS_DEST}",
        "--type=method_call",
        "/org/mpris/MediaPlayer2",
        f"org.mpris.MediaPlayer2.Player.{method}",
        *args,
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        log("dbus", method, "failed:", proc.stderr.strip())
        return False
    return True


def play_on_spotify(track_id: str) -> bool:
    # OpenUri only autoplays when the client is paused and the URI carries a
    # non-zero offset — hence the '#0:00.001'. Without it the client loads the
    # track and sits there, which mirrors nothing.
    return mpris("OpenUri", f"string:spotify:track:{track_id}#0:00.001")


def today() -> str:
    return dt.date.today().isoformat()


class Budget:
    """Spotify Free hands each account an undocumented daily on-demand quota.

    Burning it on mirrored playback would break real listening later in the day,
    so the mirror keeps its own conservative ledger and stops early.
    """

    def __init__(self) -> None:
        raw = load_state("mirror-budget.json", {})
        self.day = raw.get("day", today())
        self.seconds = raw.get("seconds", 0)
        self.roll()

    def roll(self) -> None:
        if self.day != today():
            self.day, self.seconds = today(), 0
            self.save()

    def save(self) -> None:
        save_state("mirror-budget.json", {"day": self.day, "seconds": self.seconds})

    def spend(self, seconds: int) -> None:
        self.roll()
        self.seconds += seconds
        self.save()

    def exhausted(self) -> bool:
        self.roll()
        return self.seconds >= MIRROR_DAILY_LIMIT_MINUTES * 60

    def remaining_minutes(self) -> int:
        return max(0, MIRROR_DAILY_LIMIT_MINUTES - self.seconds // 60)


def user_is_on_spotify(sp: spotipy.Spotify) -> bool:
    """True when a real device other than ours is playing.

    One account plays on one device at a time, so mirroring while the user has
    Spotify open on their phone would yank playback away from them.
    """
    try:
        current = sp.current_playback()
    except Exception as exc:
        log("playback check failed, assuming free:", exc)
        return False
    if not current or not current.get("is_playing"):
        return False
    device = (current.get("device") or {}).get("name", "")
    return MIRROR_DEVICE.lower() not in device.lower()


def cmd_mirror(_args: argparse.Namespace) -> int:
    nd = Navidrome()
    sp = spotify()
    matcher = Matcher(sp)
    budget = Budget()
    last_key: str | None = None
    warned_budget = False

    log(f"mirror up — poll {MIRROR_POLL_SECONDS}s, budget {budget.remaining_minutes()}min left today")

    while True:
        try:
            entries = [e for e in nd.now_playing() if e.get("username") == NAVIDROME_USER]
            entry = entries[0] if entries else None

            if entry is None:
                last_key = None
            else:
                song_id = str(entry.get("id"))
                if song_id != last_key:
                    last_key = song_id
                    title = entry.get("title", "")
                    artist = entry.get("artist", "")
                    secs = int(entry.get("duration", 0) or 0)

                    if secs and secs < MIRROR_MIN_TRACK_SECONDS:
                        log(f"skip (too short): {artist} — {title}")
                    elif budget.exhausted():
                        if not warned_budget:
                            log("daily mirror budget spent; idling until midnight")
                            warned_budget = True
                    elif user_is_on_spotify(sp):
                        log(f"skip (you are on Spotify elsewhere): {artist} — {title}")
                    else:
                        warned_budget = False
                        track_id = matcher.find(title, artist, secs)
                        matcher.flush()
                        if track_id is None:
                            log(f"no Spotify match: {artist} — {title}")
                        elif play_on_spotify(track_id):
                            budget.spend(secs or 200)
                            log(
                                f"mirrored: {artist} — {title} "
                                f"(spotify:track:{track_id}, {budget.remaining_minutes()}min left)"
                            )
        except requests.RequestException as exc:
            log("navidrome unreachable:", exc)
        except Exception as exc:  # a bad track must not kill a long-running daemon
            log("mirror error:", exc)

        time.sleep(MIRROR_POLL_SECONDS)


# ---------------------------------------------------------------------------
# sync — playlists in both directions, plus SoundCloud ingest
# ---------------------------------------------------------------------------

MAX_DOWNLOADS_PER_RUN = int(os.environ.get("MAX_DOWNLOADS_PER_RUN", "25"))
_FS_UNSAFE = re.compile(r"[^\w\-\.\[\] ]+", re.UNICODE)


def safe_filename(name: str) -> str:
    return _FS_UNSAFE.sub("_", name).strip()[:120] or "untitled"


def chunked(items: list[Any], size: int) -> Iterable[list[Any]]:
    for i in range(0, len(items), size):
        yield items[i : i + size]


def spotify_playlist_tracks(sp: spotipy.Spotify, playlist_id: str) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    page = sp.playlist_items(playlist_id, additional_types=("track",), limit=100)
    while page:
        for row in page["items"]:
            track = row.get("track")
            if track and track.get("id") and not track.get("is_local"):
                out.append(track)
        page = sp.next(page) if page.get("next") else None
    return out


def spotify_liked_tracks(sp: spotipy.Spotify) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    page = sp.current_user_saved_tracks(limit=50)
    while page:
        out.extend(row["track"] for row in page["items"] if row.get("track"))
        page = sp.next(page) if page.get("next") else None
    return out


class LocalCache:
    """Spotify track -> Navidrome song, persisted.

    A liked-songs list of a few hundred tracks would otherwise mean a thousand
    Subsonic searches every half hour. Negative results are cached too, so
    tracks the library genuinely lacks are not re-searched forever. `sync
    --refresh` throws the whole thing away when files have moved.
    """

    def __init__(self, refresh: bool = False) -> None:
        self.data: dict[str, dict[str, Any] | None] = {} if refresh else load_state("local-cache.json", {})
        self.dirty = refresh

    def flush(self) -> None:
        if self.dirty:
            save_state("local-cache.json", self.data)
            self.dirty = False

    def get(self, nd: Navidrome, title: str, artist: str, secs: int) -> dict[str, Any] | None:
        key = f"{norm(artist)}|||{norm(title)}"
        if key in self.data:
            song = self.data[key]
            # A cached path that no longer exists means the library moved under
            # us; fall through and search again rather than emit a dead entry.
            if song is None or (song_path(song) or Path("/nonexistent")).exists():
                return song
        song = find_local(nd, title, artist, secs)
        self.data[key] = song
        self.dirty = True
        return song


def find_local(nd: Navidrome, title: str, artist: str, secs: int) -> dict[str, Any] | None:
    """Best Navidrome song for a Spotify track, or None if we simply lack it."""
    seen: dict[str, dict[str, Any]] = {}
    for query in (f"{primary_artist(artist)} {title}", title):
        try:
            for song in nd.search_song(query):
                seen[str(song.get("id"))] = song
        except Exception as exc:
            log("navidrome search failed:", exc)
    best: tuple[float, dict[str, Any] | None] = (0.0, None)
    for song in seen.values():
        cand = score(
            title,
            artist,
            secs,
            song.get("title", ""),
            song.get("artist", ""),
            int(song.get("duration", 0) or 0),
        )
        if cand > best[0]:
            best = (cand, song)
    return best[1] if best[0] >= 0.6 else None


def song_path(song: dict[str, Any]) -> Path | None:
    raw = song.get("path")
    if not raw:
        return None
    path = Path(raw)
    return path if path.is_absolute() else MUSIC_DIR / path


def write_m3u(name: str, songs: list[dict[str, Any]]) -> bool:
    """Navidrome imports .m3u found under MusicFolder, so writing one *is* the API."""
    lines = ["#EXTM3U", f"#PLAYLIST:{name}"]
    for song in songs:
        path = song_path(song)
        if path is None:
            continue
        lines.append(f"#EXTINF:{int(song.get('duration', 0) or 0)},{song.get('artist','')} - {song.get('title','')}")
        lines.append(str(path))
    body = "\n".join(lines) + "\n"

    PLAYLIST_DIR.mkdir(parents=True, exist_ok=True)
    target = PLAYLIST_DIR / f"{safe_filename(name)}.m3u"
    if target.exists() and target.read_text() == body:
        return False
    target.write_text(body)
    return True


def download_missing(missing: list[dict[str, Any]]) -> None:
    if not missing or not AUTO_DOWNLOAD:
        return
    queue = missing[:MAX_DOWNLOADS_PER_RUN]
    DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)
    template = str(DOWNLOAD_DIR) + "/{artist}/{album}/{artists} - {title}.{output-ext}"
    urls = [f"https://open.spotify.com/track/{t['id']}" for t in queue]
    log(f"fetching {len(urls)} missing track(s) via spotdl ({len(missing)} outstanding)")
    proc = subprocess.run(
        [SPOTDL_BIN, "download", *urls, "--output", template, "--print-errors"],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        log("spotdl exited", proc.returncode, proc.stderr.strip()[-500:])


def pull_playlists(nd: Navidrome, sp: spotipy.Spotify, local: LocalCache) -> list[dict[str, Any]]:
    """Spotify -> Navidrome. Returns tracks we could not match locally.

    This walks every playlist you follow, not just the ones you made, so
    Discover Weekly and Release Radar land in Navidrome too — that is most of
    the discovery value you were keeping Spotify around for.
    """
    sources: list[tuple[str, list[dict[str, Any]]]] = []

    page = sp.current_user_playlists(limit=50)
    while page:
        for pl in page["items"]:
            name = (pl or {}).get("name") or ""
            if not name or name.startswith(PUSH_PREFIX):
                continue  # ours, pushed up last run — pulling it back would loop
            sources.append((name, spotify_playlist_tracks(sp, pl["id"])))
        page = sp.next(page) if page.get("next") else None

    if SYNC_LIKED:
        sources.append(("Liked Songs", spotify_liked_tracks(sp)))

    missing: dict[str, dict[str, Any]] = {}
    changed = 0
    for name, tracks in sources:
        matched: list[dict[str, Any]] = []
        for track in tracks:
            artist = ", ".join(a["name"] for a in track["artists"])
            song = local.get(nd, track["name"], artist, round(track["duration_ms"] / 1000))
            if song:
                matched.append(song)
            else:
                missing[track["id"]] = track
        if write_m3u(f"{PULL_PREFIX}{name}", matched):
            changed += 1
        log(f"pull '{name}': {len(matched)}/{len(tracks)} local")

    log(f"pull done — {changed} playlist file(s) rewritten, {len(missing)} track(s) missing")
    return list(missing.values())


def push_playlists(nd: Navidrome, sp: spotipy.Spotify, matcher: Matcher) -> None:
    """Navidrome -> Spotify."""
    me = sp.current_user()["id"]

    remote: dict[str, str] = {}
    page = sp.current_user_playlists(limit=50)
    while page:
        for pl in page["items"]:
            if pl and pl["owner"]["id"] == me:
                remote[pl["name"]] = pl["id"]
        page = sp.next(page) if page.get("next") else None

    for pl in nd.playlists():
        name = pl.get("name", "")
        if name.startswith(PULL_PREFIX):
            continue  # came down from Spotify; pushing it back would loop
        entries = nd.playlist(pl["id"])
        uris: list[str] = []
        for song in entries:
            track_id = matcher.find(
                song.get("title", ""), song.get("artist", ""), int(song.get("duration", 0) or 0)
            )
            if track_id:
                uris.append(f"spotify:track:{track_id}")
        matcher.flush()

        target = f"{PUSH_PREFIX}{name}"
        pid = remote.get(target)
        if pid is None:
            if not uris:
                continue  # nothing to put in it; do not create an empty shell
            pid = sp.user_playlist_create(
                me, target, public=False, description="Mirrored from Navidrome by tunedeck"
            )["id"]
            remote[target] = pid

        batches = list(chunked(uris, 100))
        sp.playlist_replace_items(pid, batches[0] if batches else [])
        for batch in batches[1:]:
            sp.playlist_add_items(pid, batch)
        log(f"push '{name}': {len(uris)}/{len(entries)} on Spotify")


def pull_soundcloud() -> None:
    """SoundCloud has no usable public API, so scdl scrapes the public URLs."""
    if not SOUNDCLOUD_URLS:
        return
    target = DOWNLOAD_DIR / "SoundCloud"
    target.mkdir(parents=True, exist_ok=True)
    for url in SOUNDCLOUD_URLS:
        log("soundcloud:", url)
        proc = subprocess.run(
            [SCDL_BIN, "-l", url.strip(), "--path", str(target), "-c", "--extract-artist"],
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0:
            log("scdl exited", proc.returncode, proc.stderr.strip()[-500:])


def cmd_sync(args: argparse.Namespace) -> int:
    nd = Navidrome()
    sp = spotify()
    matcher = Matcher(sp)
    local = LocalCache(refresh=args.refresh)

    if not args.only or args.only == "soundcloud":
        pull_soundcloud()
    missing: list[dict[str, Any]] = []
    if not args.only or args.only == "pull":
        missing = pull_playlists(nd, sp, local)
    if not args.only or args.only == "push":
        push_playlists(nd, sp, matcher)

    local.flush()
    download_missing(missing)
    save_state("wanted.json", [
        {"id": t["id"], "title": t["name"], "artist": ", ".join(a["name"] for a in t["artists"])}
        for t in missing
    ])
    matcher.flush()
    nd.scan_now()
    return 0


# ---------------------------------------------------------------------------
# auth / status / entrypoint
# ---------------------------------------------------------------------------


def cmd_auth(_args: argparse.Namespace) -> int:
    print("Open the URL below, approve, then paste the full redirected URL back here.\n")
    sp = spotify(open_browser=False)
    me = sp.current_user()
    print(f"\nauthorised as {me.get('display_name')} ({me.get('id')}, {me.get('product')})")
    print(f"token cached at {STATE / 'spotify-token.json'}")
    return 0


def cmd_status(_args: argparse.Namespace) -> int:
    budget = Budget()
    wanted = load_state("wanted.json", [])
    cache = load_state("match-cache.json", {})
    hits = sum(1 for v in cache.values() if v)
    print(f"mirror budget   : {budget.remaining_minutes()}/{MIRROR_DAILY_LIMIT_MINUTES} min left today")
    local = load_state("local-cache.json", {})
    local_hits = sum(1 for v in local.values() if v)
    print(f"spotify matches : {hits} matched, {len(cache) - hits} known-missing")
    print(f"local matches   : {local_hits} matched, {len(local) - local_hits} known-missing")
    print(f"wanted tracks   : {len(wanted)}")
    for row in wanted[:15]:
        print(f"  - {row['artist']} — {row['title']}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="tunedeck", description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("auth", help="one-off Spotify OAuth handshake").set_defaults(func=cmd_auth)
    sub.add_parser("mirror", help="replay Navidrome playback on Spotify").set_defaults(func=cmd_mirror)
    sub.add_parser("status", help="show budget, cache and wanted list").set_defaults(func=cmd_status)

    sync = sub.add_parser("sync", help="reconcile playlists both ways")
    sync.add_argument("--only", choices=["pull", "push", "soundcloud"], help="run one direction only")
    sync.add_argument("--refresh", action="store_true", help="discard the local match cache first")
    sync.set_defaults(func=cmd_sync)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
