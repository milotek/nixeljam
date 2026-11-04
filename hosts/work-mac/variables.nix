{
  config,
  lib,
  ...
}: {
  config.var = {
    hostname = "milotek-mac";
    username = "milotek";
    configDirectory = "/Users/milotek/.config/nixos";

    timeZone = "Europe/London";

    git = {
      username = "Milo Tekchandani";
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
