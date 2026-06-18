{lib, ...}: {
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };

  config.var = {
    hostname = "milotek-macbook";
    username = "milotek";
    configDirectory = "/Users/milotek/.config/nixos";

    timeZone = "Europe/London";

    git = {
      username = "Milo Tekchandani";
      email = "milo@milotek.dev";
    };

    autoGarbageCollector = true;
  };
}
