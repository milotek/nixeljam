{
  config,
  lib,
  ...
}: {
  config.var = {
    hostname = "computer"; # CHANGEME
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
  };

  # DON'T TOUCH THIS
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
