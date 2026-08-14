# RESUME — nixeljam → nixy v6.0.0 migration (working notes)

This is the **new working repo** for the migration described in the plan at
`/var/lib/copyparty/Documents/V6-MIGRATION.md` (copyparty `/Documents/V6-MIGRATION.md`).
That plan file is authoritative. Read it first.

## Ground rules (from the plan — do not violate)
- **BUILD, NEVER SWITCH.** `nixos-rebuild build --flake .#<host>` only.
- The old repo `/home/milotek/.config/nixos` stays authoritative and untouched. Reference it read-only with:
  `git --git-dir=/home/milotek/.config/nixos/.git show main:path/to/file.nix`
- Work only in this repo: `/home/milotek/nixeljam-v6`.
- Strip cloudflared ingress lines from every ported `server-modules/` file; do NOT port `cloudflared.nix`.
- Do NOT port `nixos/omen.nix` (upstream laptop hw).
- v6.0.0 base has NO impermanence/disko (they came in commits after the tag) — nothing to strip there.
- Target hosts only: **pc**, **minipc**, **vps**. Old unused hosts (laptop/macbook/server/wsl/work) not ported.

## Environment note
- Running on **minipc**. Shell cwd resets to /home/milotek/.config/nixos between tool calls — always `cd` first.
- To survive SSH disconnects, run Claude Code inside **tmux**: `tmux new -s mig` then launch claude; reattach with `tmux attach -t mig`.

## Phase status
- [x] **Phase 0 — scaffold** (this commit): new repo from v6.0.0 tag; removed hosts/laptop + hosts/server;
      flake nixosConfigurations reduced to h-work only (temporary reference host that evaluates).
      TODO before closing Phase 0: `nix flake check` / eval h-work to confirm the bare tree evaluates.
- [ ] **Phase 1 — shared modules**: port `nixos/` (reverse-tunnel, tailscale, ssh, ydotool, gaming, ollama,
      user-password, usbguard — NOT omen) and `themes/` (pixeljam, catppuccin; nixy.nix has a 9-line local diff).
      Diff ours vs upstream where both exist; keep ours only on real local change.
- [ ] **Phase 2 — pc**: host files + secrets + home modules. Do the gui/tui split and grab-bag breakup here.
      Build `.#pc`.
- [ ] **Phase 3 — minipc**: host files + secrets + self-hosted server-modules
      (caddy/copyparty/home-assistant/navidrome/slskd) + reverse tunnel. Omit creative tooling. Build `.#minipc`.
- [ ] **Phase 4 — vps**: last. caddy.nix + fail2ban.nix + disko + GatewayPorts/firewall. Build `.#vps`.
- [ ] **Phase 5 — cutover**: only once all build clean. Decide repo name then.

## v6 base structure (reference)
- Per-host dir: `flake.nix` (nixosSystem), `configuration.nix` (system imports), `home.nix` (HM imports),
  `variables.nix` (`config.var`), `hardware-configuration.nix`, `secrets/`.
- Top flake wires each host via `import ./hosts/<h>/flake.nix args`.
- home split: `home/programs/{gui,tui,group}` and `home/system/`.
- Secrets: home-manager sops via `hosts/<h>/secrets/default.nix` + `secrets.yaml`; `.sops.yaml` rules emitted there.
  NOTE: `hosts/vps/secrets` in the OLD repo is a *system* sops module imported by configuration.nix — don't import from home.nix.

## Old repo file inventory (what needs porting)
nixos/: amd-graphics, audio, bluetooth, docker, fonts, gaming*, home-manager, hyprland, nix, nvidia,
        ollama*, omen(SKIP), reverse-tunnel*, ssh*, systemd-boot, tailscale*, tuigreet, usbguard*,
        user-password*, users, utils, ydotool*   (* = ours / no upstream equiv or needs diff)
themes/: catppuccin*, nixy(9-line diff), pixeljam*
server-modules/: adguardhome, arr, awesome-wallpapers, blog, caddy*, cloudflared(SKIP), copyparty*,
        cyberchef, default-creds, fail2ban, firewall, gitea, glance/, home-assistant*, iknowyou,
        kernel-hardening, mazanoke, mealie, mk-container, navidrome*, slskd*, ssh, stirling-pdf, umami
home/programs (ours, no upstream): ai, blender, chrome, godot, nightshift, opencode, rclone, roblox,
        rofi, spotify, gpu-screen-recorder, remote-desktop, hyprpaper
home/programs (diff vs upstream new paths): shell, nvf, git, ghostty, yazi, zellij, thunar, spotatui, nix-utils
Deliberately NOT ported: home/graphical.nix, home/system/caelestia-shell/ (take v6 waybar instead).

Hosts to build: pc, minipc, vps. See old `hosts/<h>/` for configuration.nix/home.nix/variables.nix/secrets/.
