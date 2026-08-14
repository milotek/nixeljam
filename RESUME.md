# RESUME — nixeljam → nixy v6.0.0 migration (working notes)

This is the **new working repo** for the migration described in the plan at
`/var/lib/copyparty/Documents/V6-MIGRATION.md` (copyparty `/Documents/V6-MIGRATION.md`).
That plan file is authoritative. Read it first.

## Ground rules (from the plan — do not violate)
- **BUILD, NEVER SWITCH.** `nixos-rebuild build --flake .#<host>` only.
- **DISK CONSTRAINT (2026-08-14):** minipc `/nix/store` is at 95% (~6.2G free) and minipc is a LIVE
  self-hosting box (copyparty/navidrome/home-assistant). Do NOT run heavy `nix build` of pc's full closure
  here — blender(~4.2G)+steam+nvidia would overflow the disk and disrupt live services. **Gate ports with
  `nix eval ...system.build.toplevel.drvPath` (free, no disk).** Run the heavy `nixos-rebuild build .#pc`
  on pc itself, or after the user frees space / GCs. Don't nix-collect-garbage minipc autonomously.
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
- [x] **Phase 1 — shared modules** (done):
      - nixos/ ours-only ported verbatim: gaming, ollama, reverse-tunnel, ssh, tailscale, user-password, ydotool.
      - nixos/nvidia.nix: took OURS wholesale (v6 base is laptop PRIME-offload; our pc is desktop dedicated GPU).
      - nixos/nix.nix: merged our sudo NOPASSWD-nixos-rebuild rule + timestamp_timeout onto v6 base.
      - nixos/utils.nix: replaced v6 `console.keyMap` with `console.useXkbConfig=true` (gb→uk fix); added EDITOR=nvim.
      - themes/: ported pixeljam + catppuccin; fixed both to v6 theme schema (bar-height, dropped fetch/bar-thickness).
      - Kept v6 base for: amd-graphics, audio, bluetooth, docker, fonts, hyprland, systemd-boot, tuigreet, usbguard,
        users, home-manager(deferred). See DROPPED list below.
      - DEFERRED: nixos/home-manager.nix extraSpecialArgs — v6 passes pkgs-unstable; old passed pkgs-stable +
        pkgs-nur-hadi. Resolve in Phase 2 once we know which home modules reference those. gaming.nix needs the
        `nix-flatpak` flake input+module wired on pc.
      - DROPPED local tweaks (reconsider only if something breaks): wheelNeedsPassword=false (redundant + less
        secure, replaced by targeted NOPASSWD rule); fcitx5 input method (CJK, unused); docker_29 pin (kept v6
        default + lazydocker); wireplumber camera-disable; hyprland flake input (kept nixpkgs hyprland);
        source-sans/extra-cachix substituters. themes/nixy.nix local diff not ported (no host uses nixy theme).
- [x] **Phase 2 — pc** (EVAL PASSES — `nixos-system-pc-26.05` drv builds in eval; heavy `nix build` deferred, see disk note):
      - hosts/pc/: hardware-configuration.nix, variables.nix, secrets/, profile_picture.png (verbatim);
        configuration.nix, home.nix, flake.nix written for v6.
      - Flake: added inputs nix-flatpak + spicetify-nix; registered nixosConfigurations.pc; nur overlay +
        sops-nix + nix-flatpak modules in host flake. Dropped hyprland/dotfiles/caelestia inputs (unused).
      - Resolved home-manager.nix args question: v6 convention = pkgs + pkgs-unstable + NUR via overlay
        (pkgs.nur.repos.anotherhadi.*). Kept v6's home-manager.nix (no change needed).
      - Browser: kept CHROME (our chrome module = programs.chromium); swapped v6's helium refs to
        google-chrome in system/hyprland bindings + windowrules + proton. Did NOT import gui/helium.
      - Dropped: caelestia-shell (→ v6 waybar/tofi/swaync/hyprlock/hypridle/clipboard), rofi (→ tofi),
        keyboard-backlight (laptop), home/system/hyprpaper (identical to v6 hyprland/hyprpaper.nix),
        basic-apps/misc grab bags (superseded by v6 gui/tui pkgs.nix; added wiremix back).
      - console.keyMap per-host override no longer needed (utils.nix useXkbConfig handles gb→uk).
      - GATE: `nix eval .#nixosConfigurations.pc.config.system.build.toplevel.drvPath` (running).
        Iterate on eval errors, THEN `nixos-rebuild build --flake .#pc` (never switch).
      - TODO/notes: mime associations still point at helium/elio (won't break build, wrong "open with");
        gpu-screen-recorder ShadowPlay keybind (Page_Down) was in old caelestia bindings, not re-added.
- [x] **Phase 3 — minipc** (EVAL PASSES — `nixos-system-minipc-26.05`):
      - hosts/minipc: static files verbatim; configuration.nix (server-modules + reverse-tunnel forwards
        2223/3923/4533/5030/8123 + sops.defaultSopsFile=system-secrets.yaml), home.nix (lighter subset,
        no creative tooling, no monitor override), flake.nix (nur overlay + sops, no nix-flatpak/spicetify).
      - server-modules ported: copyparty, navidrome, slskd, home-assistant (ours, verbatim);
        adguardhome cloudflared ingress line stripped (only file that had it for minipc).
      - minipc secrets/default.nix is an empty placeholder; system secrets come via defaultSopsFile path.
- [x] **Phase 4 — vps** (EVAL PASSES — `nixos-system-vps-26.05`, aarch64):
      - hosts/vps: static files + disko.nix verbatim; configuration.nix (caddy + fail2ban + user-password +
        tailscale + ssh + GatewayPorts=clientspecified + firewall 2222/2223 + inline home-manager useGlobalPkgs),
        home.nix (shell/git/nix-utils), flake.nix (system=aarch64-linux, disko module).
      - server-modules/caddy.nix ported verbatim; flake gained `disko` input; vps registered; h-work removed.
      - vps home extraSpecialArgs simplified to {inherit inputs;} (no pkgs-unstable/nur needed; top-flake
        pkgs-unstable is x86_64-only anyway).
- [ ] **Phase 5 — cutover** (NOT done — needs the user):
      - **All three hosts eval clean** (pc/minipc/vps toplevel drvPaths build under `nix eval`).
      - STILL TODO before cutover:
        1. **Heavy real build** of each host: `nixos-rebuild build --flake .#<host>` (or
           `nix build .#nixosConfigurations.<host>.config.system.build.toplevel`). NOT run here — minipc disk
           was at 95%/6.2G free and it's a live server. Run on pc / after freeing space. Compare closures:
           `nix path-info -Sh ./result`; confirm minipc shed the creative tooling (~5GiB less; blender=4.2G).
        2. Diff installed package sets old-vs-new per host to confirm nothing silently dropped.
        3. Decide the repo's final name/location and whether it replaces `nixeljam` (open decision).
      - Minor polish (non-blocking, noted in Phase 2): mime associations still point at helium/elio (wrong
        "open with", won't break build); `elio` file-manager not imported though `$mod,E` binding references it;
        gpu-screen-recorder ShadowPlay keybind (Page_Down) from old caelestia bindings not re-added.

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
