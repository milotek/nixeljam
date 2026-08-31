{
  pkgs,
  lib,
  config,
  ...
}: let
  colors = config.lib.stylix.colors;
  scripts = import ../waybar/scripts.nix {inherit pkgs config;};
  obsidian = import ../../programs/gui/obsidian/package.nix {inherit pkgs lib config;};

  mkMenu = menu: let
    configFile = pkgs.writeText "config.yaml" (
      lib.generators.toYAML {} {
        anchor = "bottom-right";
        border = "#${colors.base0D}80";
        background = "#${colors.base01}EE";
        color = "#${colors.base05}";
        margin_right = 15;
        margin_bottom = 15;
        rows_per_column = 5;

        inherit menu;
      }
    );
  in
    pkgs.writeShellScriptBin "menu" ''
      exec ${lib.getExe pkgs.wlr-which-key} ${configFile}
    '';
in {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";
    "$shiftMod" = "SUPER_SHIFT";

    bind =
      [
        # Applications
        (
          "$shiftMod, A, exec, "
          + lib.getExe (mkMenu [
            {
              key = "a";
              desc = "Proton Authenticator";
              cmd = "env WEBKIT_DISABLE_COMPOSITING_MODE=1 ${pkgs.proton-authenticator}/bin/proton-authenticator";
            }
            {
              key = "p";
              desc = "Proton Pass";
              cmd = "${pkgs.proton-pass}/bin/proton-pass";
            }
            {
              key = "v";
              desc = "Proton VPN";
              cmd = "${pkgs.proton-vpn}/bin/protonvpn-app";
            }
            {
              key = "c";
              desc = "Proton Calendar";
              cmd = "${config.programs.chromium.package}/bin/google-chrome-stable 'https://calendar.proton.me/'";
            }
            {
              key = "m";
              desc = "Proton Mail";
              cmd = "${config.programs.chromium.package}/bin/google-chrome-stable 'https://mail.proton.me/'";
            }
            {
              key = "o";
              desc = "Obsidian";
              cmd = "${obsidian}/bin/obsidian";
            }
            {
              key = "s";
              desc = "Signal";
              cmd = "${pkgs.signal-desktop}/bin/signal-desktop";
            }
            {
              key = "t";
              desc = "TickTick";
              cmd = "${pkgs.ticktick}/bin/ticktick";
            }
            {
              key = "b";
              desc = "Chrome";
              cmd = "${config.programs.chromium.package}/bin/google-chrome-stable";
            }
            {
              key = "i";
              desc = "Chrome (Incognito)";
              cmd = "${config.programs.chromium.package}/bin/google-chrome-stable --incognito";
            }
          ])
        )

        "$mod,B, exec, uwsm app -- ${config.programs.chromium.package}/bin/google-chrome-stable" # Browser

        # Quick launch
        "$mod,RETURN, exec, ${pkgs.ghostty}/bin/ghostty +new-window" # Ghostty (terminal, via daemon D-Bus)
        "$mod,E, exec, ${pkgs.thunar}/bin/thunar" # Thunar

        # Windows
        "$mod,Q, killactive," # Close window
        "$mod,F, fullscreen" # Toggle Fullscreen
        "$shiftMod,F, togglefloating," # Toggle Floating
        "$shiftMod, SPACE, exec, ${scripts.focus-toggle}/bin/focus-toggle" # Toggle focus mode

        # App shortcuts (caps sends Super; forward as Ctrl to the focused app)
        "$mod,C, sendshortcut, CTRL, Insert" # Copy (Ctrl+Insert, so a terminal never reads it as SIGINT)
        "$mod,V, sendshortcut, CTRL, V" # Paste
        "$mod,W, sendshortcut, CTRL, W" # Close tab

        # Focus Windows
        "$mod,H, movefocus, l" # Move focus left
        "$mod,J, movefocus, d" # Move focus Down
        "$mod,K, movefocus, u" # Move focus Up
        "$mod,L, movefocus, r" # Move focus Right
        "$shiftMod,H, focusmonitor, -1" # Focus previous monitor
        "$shiftMod,J, layoutmsg, removemaster" # Remove from master
        "$shiftMod,K, layoutmsg, addmaster" # Add to master
        "$shiftMod,L, focusmonitor, 1" # Focus next monitor

        # Special workspaces
        "$mod, S, togglespecialworkspace, scratch" # Toggle scratch workspace
        "$shiftMod, S, movetoworkspace, special:scratch" # Move to scratch workspace

        # Utilities
        ", Print, exec, ${pkgs.hyprshot}/bin/hyprshot -m region" # Capture region
        "$shiftMod, Print, exec, ${pkgs.hyprshot}/bin/hyprshot -m output" # Capture screen
      ]
      ++ [
        "$mod, SPACE, exec, ${pkgs.tofi}/bin/tofi-drun" # Launcher
        "$mod, N, exec, ${pkgs.swaynotificationcenter}/bin/swaync-client -t" # Notification center

        # Power
        (
          "$mod, X, exec, "
          + lib.getExe (mkMenu [
            {
              key = "l";
              desc = "Lock";
              cmd = "${pkgs.hyprlock}/bin/hyprlock";
            }
            {
              key = "s";
              desc = "Suspend";
              cmd = "systemctl suspend";
            }
            {
              key = "r";
              desc = "Reboot";
              cmd = "systemctl reboot";
            }
            {
              key = "p";
              desc = "Power Off";
              cmd = "systemctl poweroff";
            }
          ])
        )
      ]
      ++ (builtins.concatLists (
        builtins.genList (
          i: let
            ws = i + 1;
          in [
            "$mod,code:1${toString i}, workspace, ${toString ws}"
            "$mod SHIFT,code:1${toString i}, movetoworkspace, ${toString ws}"
          ]
        )
        9
      ));

    bindm = [
      "$mod,mouse:272, movewindow" # Move Window (mouse)
      "$mod,R, resizewindow" # Resize Window (mouse)
    ];

    bindl =
      [
        # Media
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioPause, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
        ", XF86AudioStop, exec, ${pkgs.playerctl}/bin/playerctl stop"
      ]
      ++ [
        # Brightness
        ", XF86MonBrightnessUp, exec, ${scripts.bright-up}/bin/bright-up"
        ", XF86MonBrightnessDown, exec, ${scripts.bright-down}/bin/bright-down"

        # Sound
        ", XF86AudioMute, exec, ${scripts.vol-mute}/bin/vol-mute"
        ", XF86AudioRaiseVolume, exec, ${scripts.vol-up}/bin/vol-up"
        ", XF86AudioLowerVolume, exec, ${scripts.vol-down}/bin/vol-down"
        ", XF86AudioMicMute, exec, ${scripts.mic-mute}/bin/mic-mute"
      ];
  };
}
