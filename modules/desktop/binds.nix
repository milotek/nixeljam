# Personal keybinds on top of niri.nix: Ctrl closes windows like the rest of the
# Ctrl-for-apps scheme (see ghostty.nix), Alt+Space opens the launcher too.
{
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    (
      {
        lib,
        pkgs,
        ...
      }: {
        xdg.configFile."niri/personal.kdl".text = ''
          binds {
              Ctrl+Q repeat=false { close-window; }
              Mod+E { spawn "thunar"; }
              Alt+Space { spawn "${pkgs.noctalia-shell}/bin/noctalia-shell" "ipc" "call" "launcher" "toggle"; }
          }
        '';
        xdg.configFile."niri/config.kdl".text = lib.mkAfter ''
          include "./personal.kdl"
        '';
      }
    )
  ];
}
