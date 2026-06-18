{lib, ...}: {
  options = {
    var = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
  };

  config.var = {
    username = "milotek";

    git = {
      username = "Milo Tekchandani";
      email = "milo@milotek.dev";
    };
  };
}
