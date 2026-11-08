# swayidle handles idle management: lock the screen, turn the display off, and
# suspend after periods of inactivity. noctalia's idle inhibitor pauses it.
{
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    (
      {
        osConfig,
        pkgs,
        ...
      }: let
        lock = "${pkgs.noctalia-shell}/bin/noctalia-shell ipc call lockScreen lock";
      in {
        services.swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 300; # 5 min → lock
              command = lock;
            }
            {
              timeout = 720; # 12 min → screen off
              command = "${osConfig.programs.niri.package}/bin/niri msg action power-off-monitors";
            }
            {
              timeout = 1800; # 30 min → suspend
              command = "${pkgs.systemd}/bin/systemctl suspend";
            }
          ];
          events = {
            before-sleep = lock;
            lock = lock;
          };
        };
      }
    )
  ];
}
