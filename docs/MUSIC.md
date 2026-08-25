# MUSIC

How the self-hosted music stack relates to Spotify, SoundCloud and listening
stats. Three NixOS modules, one helper package.

| Piece | File | What it does |
| --- | --- | --- |
| Navidrome | `server-modules/navidrome.nix` | the library, plus native Last.fm / ListenBrainz scrobbling |
| tunedeck (base) | `server-modules/tunedeck.nix` | shared package, secrets and env file |
| spotify-mirror | `server-modules/spotify-mirror.nix` | replays Navidrome playback on a real Spotify client |
| playlist-sync | `server-modules/playlist-sync.nix` | two-way playlists, SoundCloud pull, auto-download |
| tunedeck | `pkgs/tunedeck/` | the Python that does all of it |

Knobs live in `hosts/minipc/variables.nix` under `var.tunedeck`.

## The honest part first

**Spotify has no ingest API.** There is no endpoint anywhere that accepts "I
listened to this track". Your Spotify history is generated server-side, only
from playback that really happened on a Spotify client. stats.fm just reads
Spotify's API, so it inherits that exactly — and on the free tier it cannot even
take a manual history import, since that is a stats.fm Plus feature.

So there is no honest way to *scrobble* Navidrome plays into Spotify. The only
thing that ever counts is real playback. `spotify-mirror` produces real
playback; nothing else could have worked.

## spotify-mirror

Runs the actual Spotify desktop client on the minipc, headless under Xvfb, with
its audio routed into a PipeWire null sink. A daemon polls Navidrome's Subsonic
`getNowPlaying`, resolves the track on Spotify, and fires
`org.mpris.MediaPlayer2.Player.OpenUri` at the client over D-Bus. The client
streams it for real. It counts for stats.fm, for Wrapped, for the
recommendation algorithm, and it pays the artist.

Why the desktop client and not `librespot` or the Web API: both of those need
Premium. The desktop client has done on-demand playback of any track on the free
tier since September 2025, and MPRIS is the only remote control it exposes.

Three guards keep it from being obnoxious:

- **Daily budget.** Free accounts get an undocumented on-demand allowance.
  tunedeck keeps its own ledger (`var.tunedeck.mirrorDailyLimitMinutes`,
  default 240) and stops early rather than spending the quota you wanted for
  real listening.
- **Yield to the human.** One account plays on one device at a time. Before
  mirroring anything the daemon reads `/me/player`; if another device is
  playing, it stands down. It will never yank playback off your phone.
- **Skip the unmirrorable.** Tracks under 35s, and anything with no confident
  Spotify match, are skipped rather than guessed at.

Ads play into the null sink and cost a little budget. Nothing breaks.

**The risk, plainly:** this is automated playback of audio nobody is hearing,
which is the shape Spotify's artificial-streaming detection looks for. You are
genuinely listening, just on a different player — but the account risk is real
and it is yours. It is a free account, so there is not much to lose.

### Setup

No Spotify app registration by default — see *Credentials* below.

1. `nixos-rebuild switch --flake .#minipc`
2. `tunedeck-console` — prints a URL. Open it from any tailnet device,
   including a phone. That is the headless display, and the Spotify window is
   already sitting on it showing a login screen with a **QR code**. Scan it
   with the Spotify app on your phone. No password is typed anywhere.
3. `sudo -u milotek tunedeck-auth` — paste the URL back when prompted. The
   consent screen will say **spotDL**; that is expected.
4. `systemctl restart tunedeck-mirror`

### The console

`minipc` has no desktop session, so there is normally no way to click the one
button Spotify insists on. `tunedeck-console` solves that: Xvfb on `:97` with
openbox, x11vnc bound to localhost, and noVNC bridged onto port 6081. Same
trust model as `home/system/remote-desktop` — VNC is unauthenticated and the
tailnet is the authentication, and `trustedInterfaces = ["tailscale0"]` means
no port needed opening.

`tunedeck-browser <url>` puts a real desktop browser on that same display,
which is also how to reach the Spotify developer dashboard when a phone
refuses to render it.

It is strictly more exposure than the pc's remote desktop, because anyone on
the tailnet can drive that browser as your user. Set `var.tunedeck.console =
false` once setup is done.

Check on it:

```sh
sudo -u milotek tunedeck-auth status
journalctl -fu tunedeck-mirror
```

## Credentials

The Web API is needed for three things MPRIS cannot do: **search** (turning
"Radiohead — Creep" into a track id, without which the mirror has nothing to
hand the client), **`/me/player`** (the guard that yields when you are playing
elsewhere), and **playlists** (the whole sync half).

By default tunedeck rides spotdl's credentials. spotdl hardcodes a public
client id/secret and writes them to `~/.config/spotdl/config.json` on first
run, which is why none of this ever needed registering. Its app has
`http://127.0.0.1:9900/` registered as a redirect URI, and Spotify does not
pre-register scopes per app, so tunedeck's scopes go through it fine.

What that costs: the rate limit is shared with every spotdl user in the world,
so heavy sync runs may see 429s, and if Spotify ever revokes that app
everything here stops at once. The OAuth consent screen also says "spotDL",
because it is.

To use your own app instead: register one at
<https://developer.spotify.com/dashboard> with redirect URI exactly
`http://127.0.0.1:8974/callback`, put `spotify-client-id` and
`spotify-client-secret` in `sops hosts/minipc/secrets/system-secrets.yaml`, and
set `var.tunedeck.ownSpotifyApp = true`. Re-run `tunedeck-auth` afterwards —
switching apps invalidates the cached token.

## playlist-sync

Everything here works on a free account — reading your playlists and liked
songs, and creating playlists you own, are all free-tier operations. A timer
runs every 30 minutes.

```
SoundCloud  ──scdl──▶  <music>/Songs/Tunedeck/SoundCloud
Spotify     ──────▶    matched against the library, written as .m3u
                       into <music>/Playlists  (Navidrome auto-imports these)
unmatched   ──spotdl─▶ <music>/Songs/Tunedeck   (next run matches them locally)
Navidrome   ──────▶    pushed up to a Spotify playlist you own
```

It walks **every playlist you follow**, not just the ones you made — so
Discover Weekly and Release Radar land in Navidrome too, which is most of the
discovery value Spotify was being kept around for.

**Loop prevention:** pulled playlists are named `[sp] Foo` locally, pushed ones
`[nd] Bar` on Spotify. Each direction skips the other's prefix. Do not rename
them by hand.

SoundCloud is the weak link: they closed the public API to new apps years ago,
so `scdl` scrapes public URLs. Put them in `var.tunedeck.soundcloudUrls`.

Manual runs:

```sh
systemctl start tunedeck-sync                      # everything, now
sudo -u milotek tunedeck-auth sync --only pull     # or push / soundcloud
sudo -u milotek tunedeck-auth sync --refresh       # after moving files around
```

### Matching

Title and artist are hard gates; duration only breaks ties. Same title under a
different artist is treated as a cover and rejected, because letting a close
duration drag those over the line produced exactly the wrong matches in testing.
Remaster/live/feat. suffixes are stripped before comparison. See
`pkgs/tunedeck/test_match.py` for the cases that pin this down.

Both directions cache their matches, negatives included, in `/var/lib/tunedeck`.
Without that a few hundred liked songs would mean a thousand Subsonic searches
every half hour.

## Stats, without the mirror

The mirror is the hacky answer to "make it count on stats.fm". The robust answer
to "put all my listening in one place" does not involve Spotify at all:

- Navidrome scrobbles natively to **ListenBrainz** (on by default; paste your
  token in the Navidrome UI under Personal → Settings) and to **Last.fm** (set
  `var.tunedeck.lastfm = true` once `lastfm-api-key` / `lastfm-secret` are in
  sops — Navidrome ships no API key of its own).
- Last.fm can pull your Spotify plays in by itself: Last.fm → Settings →
  Applications → connect Spotify. No software involved.

That gives one unified history across both players, which is the thing stats.fm
structurally cannot do — it only ever sees Spotify. ListenBrainz also does real
recommendation playlists off the full history, and Navidrome's Last.fm agent
surfaces similar artists in the UI.

## Files on disk

```
/var/lib/copyparty/Music/
├── Playlists/                 .m3u written by playlist-sync, read by Navidrome
└── Songs/
    ├── Soulseek/              slskd downloads
    └── Tunedeck/              spotdl + scdl downloads
        └── SoundCloud/
/var/lib/tunedeck/
├── spotify-token.json         OAuth refresh token
├── spotify-home/              the headless client's profile
├── match-cache.json           navidrome track -> spotify id
├── local-cache.json           spotify track -> navidrome song
├── mirror-budget.json         today's spent minutes
└── wanted.json                tracks the library still lacks
```
