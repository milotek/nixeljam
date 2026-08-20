{
  config,
  lib,
  ...
}: {
  config.var = {
    hostname = "milotek-mac";
    username = "milotek";
    # Path of the nixos configuration directory on this machine.
    configDirectory = "/Users/milotek/.config/nixos";

    timeZone = "Europe/London";

    git = {
      username = "Milo Tekchandani";
      # CHANGEME: set a work email here if you want work commits attributed differently.
      email = "milo@milotek.dev";
    };

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
