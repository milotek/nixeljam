{
  config,
  lib,
  ...
}: {
  imports = [
    ../../themes/pixeljam.nix
  ];

  config.var = {
    hostname = "minipc";
    username = "milotek";
    configDirectory = "/home/" + config.var.username + "/.config/nixos";

    keyboardLayout = "gb";

    timeZone = "Europe/London";
    defaultLocale = "en_GB.UTF-8";
    extraLocale = "en_US.UTF-8";

    git = {
      username = "Milo Tekchandani";
      email = "milo@milotek.dev";
    };

    # Serve this host's zellij sessions to a browser at term.minipc.<domain>.
    # Read by both server-modules/zellij-web.nix and the zellij home module.
    zellijWeb = true;

    autoUpgrade = false;
    autoGarbageCollector = true;

    domain = "tek.rip";
  };

  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };
}
