# Caelestia is a Quickshell desktop shell: bar, launcher, notifications, lock
# screen and session menu in one process.
#
# It replaces the waybar stack rather than sitting alongside it. A host that
# wants it drops the waybar/tofi/swaync/hyprlock imports from its home.nix,
# imports this instead, and sets `var.desktopShell = "caelestia"` so
# home/system/hyprland/bindings.nix hands the shell-owned keys over.
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.caelestia-shell.homeManagerModules.default
    ./appearance.nix
    ./bar.nix
    ./bindings.nix
    ./launcher.nix
    ./scheme.nix
  ];

  programs.caelestia = {
    enable = true;
    # The shell is started from hyprland's exec-once below; a user unit would
    # race the compositor and come up before there is a Wayland socket to bind.
    systemd.enable = false;

    settings = {
      general = {
        apps = {
          terminal = ["ghostty"];
          audio = ["pavucontrol"];
          explorer = ["thunar"];
        };
        # Idle handling stays with hypridle, which is configured per-host.
        idle.timeouts = [];
      };

      notifs.actionOnClick = true;

      services = {
        brightnessIncrement = 0.05;
        useTwelveHourClock = false;
        weatherLocation = "London";
      };
    };

    cli = {
      enable = true;
      # Every theming target below is already owned by stylix; letting the CLI
      # write them too means two sources of truth fighting over the same files.
      settings.theme = {
        enableTerm = false;
        enableDiscord = false;
        enableSpicetify = false;
        enableBtop = false;
        enableCava = false;
        enableHypr = false;
        enableGtk = false;
        enableQt = false;
      };
    };
  };

  home.packages = with pkgs; [
    pavucontrol
    hyprpicker
  ];

  wayland.windowManager.hyprland.settings.exec-once = [
    "uwsm app -- caelestia shell -d"
    "uwsm app -- caelestia resizer -d"
    "caelestia scheme set --name custom -m dark"
  ];
}
