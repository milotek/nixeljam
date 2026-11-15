# Source: https://github.com/Dylouwu/MyNixy/blob/main/nixos/steam.nix
{
  flake.modules.nixos.steam = {
    config,
    pkgs,
    ...
  }: let
    # Steam launch option: `game %command%`, or `game -w 1280 -h 960 %command%` for a stretched res
    game = pkgs.writeShellApplication {
      name = "game";
      runtimeInputs = with pkgs; [gamescope jq niri];
      text = ''
        mode=$(niri msg -j focused-output 2>/dev/null | jq -r '.modes[.current_mode] | "\(.width) \(.height) \(.refresh_rate / 1000 | round)"' || true)
        read -r W H R <<< "''${mode:-1920 1080 60}"
        w=$W
        h=$H
        while [[ $# -gt 0 ]]; do
          case $1 in
            -w) w=$2; shift 2 ;;
            -h) h=$2; shift 2 ;;
            --) shift; break ;;
            *) break ;;
          esac
        done

        # gamescope's SDL breaks on Steam's LD_LIBRARY_PATH, but the game itself needs it.
        # LD_PRELOAD (the Steam overlay) slows games down after ~24 min under gamescope.
        exec env -u LD_LIBRARY_PATH -u LD_PRELOAD \
          gamescope -W "$W" -H "$H" -w "$w" -h "$h" -r "$R" -S stretch -- \
          env LD_LIBRARY_PATH="''${LD_LIBRARY_PATH:-}" "$@"
      '';
    };
  in {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    environment.systemPackages = with pkgs; [
      game
      mangohud
      protonup-ng
    ];

    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${config.var.username}/.steam/root/compatibilitytools.d";
    };

    programs.gamemode.enable = true;
  };
}
