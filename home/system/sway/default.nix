# Minimal Sway desktop for the minipc: tiling WM + waybar + fuzzel launcher.
# Colours and wallpaper come from stylix, which auto-themes both sway and waybar.
{
  pkgs,
  config,
  lib,
  ...
}: let
  mod = "Mod4"; # Super
  term = "${pkgs.ghostty}/bin/ghostty";
  menu = "${pkgs.fuzzel}/bin/fuzzel";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
in {
  home.packages = with pkgs; [
    fuzzel
    brightnessctl
    grim
    slurp
    wl-clipboard
    imv
    pavucontrol
  ];

  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      modules-left = ["sway/workspaces" "sway/mode"];
      modules-center = ["clock"];
      modules-right = ["pulseaudio" "network" "cpu" "memory" "tray"];
      clock.format = "{:%a %d %b  %H:%M}";
      cpu.format = " {usage}%";
      memory.format = " {}%";
      network = {
        format-wifi = " {essid}";
        format-ethernet = " {ifname}";
        format-disconnected = "disconnected";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "muted";
        format-icons.default = ["" "" ""];
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
      tray.spacing = 8;
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the system sway from programs.sway
    checkConfig = false; # cannot validate without the package
    config = {
      modifier = mod;
      terminal = term;
      menu = menu;
      gaps = {
        inner = 6;
        outer = 2;
      };
      input."*" = {
        xkb_layout = config.var.keyboardLayout;
        xkb_options = "caps:escape";
      };
      startup = [
        {command = "waybar";}
      ];
      # Additive binds; sway's HM defaults already cover terminal, menu,
      # workspaces, focus/move, kill, fullscreen, reload and exit.
      keybindings = lib.mkOptionDefault {
        "Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
        "XF86AudioRaiseVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute" = "exec ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
        "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
      };
    };
  };
}
