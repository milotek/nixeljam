{
  config,
  lib,
  ...
}: {
  config = {
    var = {
      hostname = "nixos"; # CHANGEME
      username = "user"; # CHANGEME
      configDirectory = "/home/" + config.var.username + "/.config/nixos"; # The path of the nixos configuration directory

      keyboardLayout = "us"; # CHANGEME

      timeZone = "America/New_York"; # CHANGEME
      defaultLocale = "en_US.UTF-8";
      extraLocale = "en_US.UTF-8"; # CHANGEME

      git = {
        username = "Your Name"; # CHANGEME
        email = "you@example.com"; # CHANGEME
      };

      autoUpgrade = false;
      autoGarbageCollector = true;
      impermanenceEnabled = false;
    };

    users.users.${config.var.username}.initialPassword = "changeme"; # CHANGEME: run `passwd` after the first login

    home-manager.users.${config.var.username} = {
      programs.nixy = {
        enable = true;
        configDirectory = config.var.configDirectory;
      };

      # Don't touch this
      home.stateVersion = "26.05";
    };

    # Don't touch this
    system.stateVersion = "26.05";
  };

  # DON'T TOUCH THIS
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
