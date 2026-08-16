# Migration plan: rebuild nixeljam on the nixy v6.0.0 base

This document is self-contained.
A session starting from scratch should be able to read only this file plus the repos it names.

## What this is

`nixeljam` (`git@github.com:milotek/nixeljam.git`) is a fork of `nixy` (https://github.com/anotherhadi/nixy).
The two diverged at commit `e2ccbac0` on 2024-03-13 and are now 1567 commits (ours) to 1507 commits (theirs) apart.
Upstream force-pushes its `main`, so there is no shared-history path back.

Upstream released **v6.0.0** on 2026-08-13 (tag `v6.0.0`, commit `0cef4320fd0708baccfdbe53c0a7c4af84226d85`).
That release restructured the home tree and replaced the bar, and subsequent commits added disko + LUKS + impermanence.

The decision is to **rebuild nixeljam on top of the v6.0.0 base**, hand-porting our configuration across rather than replaying history.
This is a rewrite that uses the existing repo as reference material, not a rebase or a merge.

## Why rebuild rather than rearrange in place

Both paths reach a similar end state.
The rebuild was chosen for one reason: mistakes accumulated during the original build should not survive the move.

On a rearrange-in-place path, anything that currently works tends to carry forward unexamined.
Starting from a clean base means nothing carries unless it is consciously moved, which forces every module to be re-read once.

This is affordable because only three hosts are in real use.
At the original eight hosts it would not have been.

## Decisions already made

**Adopt upstream's gui/tui directory split.**
v6 splits `home/programs/` into `home/programs/gui/` and `home/programs/tui/`.
Our equivalent files currently sit flat under `home/programs/`.

**Adopt explicit per-host import lists.**
Drop `home/graphical.nix`, which is a shared profile imported by pc and minipc.
Each host lists its own modules directly.
At three hosts this is more readable than the profile indirection, and it makes each host's real contents visible in one file.

**Rejected: an options plus `mkIf` architecture.**
Every module would declare `options.milo.<area>.<name>.enable` and hosts would flip flags.
This was considered and rejected as over-engineering for three hosts.
It would be the right answer at seven or more, so revisit only if the host count grows again.

**Break up the package grab bags.**
`home/programs/group/basic-apps.nix` is a single file holding roughly 40 packages, mixing GUI apps, TUIs and CLIs.
It is imported wholesale, which is how a 4.2 GiB Blender closure ended up on minipc.
Upstream v6 solved this by splitting into `gui/pkgs.nix` and `tui/pkgs.nix`, and by dropping blender, discord and obs-studio entirely.
Heavy creative tooling (blender, godot, the roblox toolchain) belongs in its own modules that only pc imports.

**Keep the old repo authoritative until every host builds.**
Work in a separate repository.
Nothing is deleted from the current repo as part of this.
Unused hosts (`laptop`, `macbook`, `server`, `wsl`, `work`) are simply not ported, which sidesteps any deletion decision.

## Open decisions

**Name and location of the new repository.**
Not yet chosen.

## The three hosts

**pc** is `milotek-pc-linux`, the daily driver.
Nvidia GPU, dual 2560x1440@144 displays on HDMI-A-1 and DP-1.
Full desktop plus gaming, creative tooling, docker, ollama.
Reaches the vps by reverse tunnel: sshd on vps port 2222, noVNC fronted by the vps caddy.

**minipc** is a desktop that also self-hosts.
Runs Hyprland with auto-detected monitors and no machine-specific display overrides.
Hosts adguardhome, fail2ban, copyparty, navidrome, slskd, home-assistant.
Reaches the vps by reverse tunnel: sshd on vps port 2223, copyparty on 3923, navidrome on 4533.
Should not receive the creative tooling.

**vps** is an Oracle Cloud aarch64 box, headless.
Deployed with `nixos-anywhere --flake .#vps --build-on remote -i ~/.ssh/github root@<ip>`.
Runs caddy and fail2ban, uses disko, terminates both reverse tunnels.

## What has to be ported

124 files exist in our tree but not upstream's.
A large share of that is v6 path renames rather than new content, so the real figure is closer to 60 or 70 files.

**`nixos/` modules with no upstream equivalent:**
`reverse-tunnel.nix`, `tailscale.nix`, `ssh.nix`, `ydotool.nix`, `gaming.nix`, `ollama.nix`, `user-password.nix`, `usbguard.nix`.
(`omen.nix` is upstream laptop hardware and should not be ported.)

**`server-modules/` with no upstream equivalent:**
`caddy.nix`, `copyparty.nix`, `home-assistant.nix`, `navidrome.nix`, `slskd.nix`.
The rest of `server-modules/` exists upstream and only needs checking for local edits.

**`themes/`:**
`pixeljam.nix` and `catppuccin.nix` are ours.
`nixy.nix` is upstream's with a nine-line local diff.
pc, minipc and vps all use pixeljam.

**Home modules with no upstream equivalent:**
`ai` (including `AGENTS.md`, `VOICE.md`, `skills.nix`), `opencode`, `rclone`, `roblox`, `godot`, `blender`, `spotify`, `chrome`, `nightshift`, `rofi`, `gpu-screen-recorder`, `remote-desktop`, `hyprpaper`.
Our `shell`, `nvf`, `git`, `ghostty`, `yazi`, `zellij`, `thunar`, `spotatui` and `nix-utils` have upstream counterparts at new v6 paths and need diffing rather than wholesale copying.

**Per host:** `configuration.nix`, `flake.nix`, `hardware-configuration.nix`, `home.nix`, `variables.nix`, `secrets/`.

**Deliberately not ported:** `home/graphical.nix` (superseded by per-host lists), `home/system/caelestia-shell/` (see below), the five unused host directories.

## The caelestia-shell question

We currently run caelestia-shell, a single integrated Quickshell desktop shell covering bar, launcher, appearance, colour scheme and screenshot annotation.
It is 773 lines across seven files in `home/system/caelestia-shell/`.
v6 goes the opposite way with waybar plus tofi plus swaync as three independently configured pieces.

There is no attachment to caelestia-shell, so the default is to take v6's waybar setup and not port caelestia across.
If waybar turns out worse in practice, caelestia-shell is still in the old repo and can be brought over as a unit.

## Networking and service exposure: keep the current model

**Decision: networking carries over unchanged.**
Reverse SSH tunnels into the vps, caddy terminating TLS in front, tailscale as a separate out-of-band admin path.
No Cloudflare Tunnel, no Pangolin, no new auth layer as part of this migration.
The vps is therefore ported, and goes last.

Upstream has no tailscale, no reverse tunnel and no `nixos/ssh.nix`.
Those three modules are entirely ours and have no upstream counterpart to reconcile against, so they port verbatim.

Upstream does share our `config.var.domain` mechanism, set per host in `variables.nix`.
Theirs is `hadi.icu`; ours is `tek.rip`, currently set only on vps.
Upstream additionally carries `config.var.tunnelId` and `config.var.networkInterface`, which we do not use.

### Required cleanup during the port

Upstream exposes services through Cloudflare Tunnel, and each of its service modules appends an ingress entry keyed on `config.var.tunnelId` and `config.var.domain`.
We inherited those modules without those variables, which is a latent bug in the current tree.

minipc imports `server-modules/adguardhome.nix`, whose line 21 dereferences both.
minipc's `variables.nix` defines neither.

```
$ nix eval .#nixosConfigurations.minipc.config.services.cloudflared.tunnels
error: attribute 'tunnelId' missing
```

The host still builds because cloudflared is disabled and NixOS never forces the option when the service is off.
`gitea.nix`, `blog.nix`, `stirling-pdf.nix` and `iknowyou.nix` carry the same pattern and would hit the same error if imported.

**Strip the `services.cloudflared.tunnels.*.ingress` lines out of every inherited `server-modules/` file as it is ported.**
Do not port `server-modules/cloudflared.nix` at all.

### Why the alternatives were rejected

**Cloudflare Tunnel** would make the vps redundant, since the vps hosts nothing of its own and exists only as a rendezvous point with a public IP.
That is genuinely attractive, but Cloudflare would terminate TLS for our files, music and home automation, and their Self-Serve Subscription Agreement section 2.8 discourages disproportionate non-HTML content through the CDN.
`music` (navidrome) and `files` (copyparty) are two of our five public vhosts and are exactly that kind of traffic.

**Pangolin** is packaged in nixpkgs and would work: `services.pangolin` (pangolin 1.21.0, aarch64-linux supported) on the vps, `services.newt` (`fosrl-newt` 1.15.0) on pc and minipc.
It was rejected because its resource mapping lives in a database behind a web dashboard rather than in the flake.
The current `server-modules/caddy.nix` is 46 declarative lines in git, and moving that into runtime state is a regression for a config-as-code setup.
Note that the `newt` and `gerbil` packages in nixpkgs are unrelated projects, not Pangolin components.

**An auth gateway (Authelia and friends)** was considered and deferred, not rejected outright.
See the deferred work section below.

### Do not gate the tailnet path

`nixos/tailscale.nix` sets `trustedInterfaces = ["tailscale0"]`, so tailnet clients reach services directly on the host and never traverse the vps or caddy.
That module exists specifically as an out-of-band admin door that does not depend on AdGuard's DNS or the tek.rip tunnel, added after a minipc lockout.
Any future auth layer must sit on the public path only.
Gating the tailnet path would reintroduce the failure mode tailscale was added to prevent.

## Traps

**Impermanence will destroy state if it leaks onto an existing install.**
The v6 base wires disko plus LUKS plus impermanence for a fresh laptop install.
pc and minipc have existing disks and existing state.
Strip impermanence and disko from the base as the first action after scaffolding, and reintroduce them only deliberately on a genuine reinstall.
Anything not explicitly persisted is discarded on boot, silently.

**Secrets are the most likely source of subtle breakage.**
age keys, host keys, `.sops.yaml` creation rules and per-host secret paths all have to line up.
pc has both `secrets/secrets.yaml` and `secrets/system-secrets.yaml`; minipc has only `system-secrets.yaml`; vps has only `secrets.yaml`.
Note that `hosts/vps/secrets` is a system-level sops module imported by `configuration.nix`, not a home-manager one, and importing it from `home.nix` will break the build.
Verify decryption per host before building anything else.

**`hardware-configuration.nix` is copied verbatim per host and never rewritten.**

**The flake needs multi-host wiring rebuilt.**
Upstream v6 has two hosts.
Ours currently wires four `nixosConfigurations`, one darwin configuration and two `homeConfigurations`, across 23 flake inputs.
The new flake needs pc, minipc and vps only.

**The vps is load-bearing for remote access.**
Both other machines reach the outside world through its tunnels.
Breaking it costs access to everything.

## Phases

**Phase 0: scaffold.**
Create the new repository and populate it from the v6.0.0 tag.
Strip impermanence, disko, usbguard-per-host and the `laptop` and `server` host directories from the base.
Confirm the bare tree evaluates.

**Phase 1: shared modules.**
Port `nixos/` and `themes/`.
Diff our versions against upstream's where both exist, and take ours only where there is a real local change worth keeping.

**Phase 2: pc.**
Port host files, secrets, then home modules.
This host is testable locally and is the one in daily use, so it shakes out the most problems.
Sort the gui/tui split and the grab-bag breakup here, since pc imports nearly everything.

**Phase 3: minipc.**
Port host files, secrets, the self-hosted `server-modules/`, and the reverse tunnel.
Deliberately omit the creative tooling.
Expect roughly 5 GiB less closure than the current configuration.

**Phase 4: vps.**
Port last.
Bring across `server-modules/caddy.nix` and `fail2ban.nix`, disko, and the `GatewayPorts` plus firewall configuration that terminates the tunnels.
Verify with a build, and keep a working ssh session open to the box before any switch, since a bad switch costs access to every machine.

**Phase 5: cutover.**
Only once all ported hosts build clean.
Decide then whether the new repo replaces `nixeljam` or takes a new name.

## Deferred work

None of the following is part of the migration.
They are recorded here so they are not lost, and because the migration should avoid making any of them harder.

**Move the noVNC basic-auth hash out of the repo.**
`server-modules/caddy.nix:38` has a bcrypt hash committed in the clear, and `milotek/nixeljam` is a public repository.
Cost 14 makes it expensive to crack, but it is an offline-crackable hash guarding a noVNC session that is itself unauthenticated, on the daily driver.
Move it to sops and rotate the password.

**Consider an auth gateway on the public path.**
Caddy's `forward_auth` is a built-in directive, so no custom caddy build is needed.
Candidates all have NixOS modules: `services.authelia` (4.39.20, passkeys and TOTP, per-resource policy), `services.tinyauth` (5.1.3, much lighter), `services.pocket-id` (2.12.0, passkey-only OIDC), `services.oauth2-proxy` (7.15.3).

Only `remote.pc` genuinely needs this.
copyparty, navidrome, slskd and home-assistant all have their own logins.

**Critical constraint if this is ever done:** do not put `forward_auth` in front of `files.tek.rip`.
`home/programs/rclone/default.nix` mounts it over WebDAV with a systemd user service, and rclone cannot complete an interactive browser login.
Adding a gateway there breaks the working `~/files` mount on pc.

**Consider whether slskd and home-assistant need public vhosts at all.**
Both are reachable over the tailnet already.
Dropping them would cut the public surface from five vhosts to three.

**Route rclone over tailscale rather than through the vps.**
`~/files` on pc currently goes internet to vps to reverse SSH tunnel to minipc, so file traffic round-trips through an Oracle free-tier box even though pc and minipc are on the same network.
Pointing rclone at minipc directly over tailscale would remove the vps from the data path.
Keep the public `files.tek.rip` vhost for access from away.

**Mac access to copyparty.**
Same rclone WebDAV pattern as pc, driven by a launchd agent instead of a systemd user service, with `fuse-t` rather than macFUSE to avoid a kernel extension on Apple Silicon.
Finder's built-in WebDAV client works with no install but is slow with large files.

## Verification

Build, never switch, until a host is fully ported:

```
nixos-rebuild build --flake .#pc
nixos-rebuild build --flake .#minipc
```

Compare closure sizes against the current configuration to confirm minipc actually shed the creative tooling:

```
nix path-info -Sh ./result
```

For reference, `pkgs.blender` alone is a 4.2 GiB closure.

Check that nothing was silently dropped by diffing the installed package sets between old and new builds for each host before cutover.

## Useful commands

```
# add upstream to the new repo
git remote add upstream https://github.com/anotherhadi/nixy.git
git fetch upstream --tags

# start from the v6.0.0 tag
git checkout -b main v6.0.0

# reference the old tree without leaving the new repo
git --git-dir=/home/milotek/.config/nixos/.git show main:path/to/file.nix

# list files unique to the old fork
comm -23 <(git ls-tree -r --name-only main | sort) \
         <(git ls-tree -r --name-only upstream/main | sort)
```
