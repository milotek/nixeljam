{
  programs.caelestia.settings = {
    session.commands = {
      logout = ["loginctl" "terminate-user" ""];
      shutdown = ["systemctl" "poweroff"];
      hibernate = ["systemctl" "hibernate"];
      reboot = ["systemctl" "reboot"];
    };

    launcher = {
      actionPrefix = "/";
      specialPrefix = "@";
      dragThreshold = 50;
      enableDangerousActions = true;
      maxShown = 6;
      maxWallpapers = 5;
      showOnHover = false;

      useFuzzy = {
        apps = true;
        actions = true;
        schemes = false;
        variants = false;
        wallpapers = true;
      };

      # TUI programs launched from a graphical launcher open a window with no
      # terminal attached, so they are never what you meant to pick.
      hiddenApps = [
        "nvim"
        "gvim"
        "xterm"
        "qt5ct"
        "qt6ct"
        "kvantummanager"
        "thunar-settings"
      ];

      actions = [
        {
          name = "Calculator";
          icon = "calculate";
          description = "Do simple math equations (powered by Qalc)";
          command = ["autocomplete" "calc"];
          enabled = true;
          dangerous = false;
        }
        {
          name = "Wallpaper";
          icon = "image";
          description = "Change the current wallpaper";
          command = ["autocomplete" "wallpaper"];
          enabled = true;
          dangerous = false;
        }
        {
          name = "Emoji Picker";
          icon = "mood";
          description = "Toggle the emoji picker";
          command = ["caelestia" "emoji" "-p"];
          enabled = true;
          dangerous = false;
        }
        {
          name = "Clipboard History";
          icon = "content_paste";
          description = "Pick from or delete clipboard history";
          command = ["caelestia" "clipboard"];
          enabled = true;
          dangerous = false;
        }
        {
          name = "Colour Picker";
          icon = "colorize";
          description = "Pick a hex colour from the screen";
          command = ["hyprpicker" "-a"];
          enabled = true;
          dangerous = false;
        }
        {
          name = "Lock";
          icon = "lock";
          description = "Lock the current session";
          command = ["loginctl" "lock-session"];
          enabled = true;
          dangerous = false;
        }
        {
          name = "Suspend";
          icon = "bedtime";
          description = "Suspend the system";
          command = ["systemctl" "suspend"];
          enabled = true;
          dangerous = false;
        }
        {
          name = "Reboot";
          icon = "cached";
          description = "Reboot the system";
          command = ["systemctl" "reboot"];
          enabled = true;
          dangerous = true;
        }
        {
          name = "Shutdown";
          icon = "power_settings_new";
          description = "Shut down the system";
          command = ["systemctl" "poweroff"];
          enabled = true;
          dangerous = true;
        }
      ];
    };
  };
}
