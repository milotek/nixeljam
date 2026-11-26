{
  flake.modules.nixos.media = {lib, ...}: {
    options.nixeljam.media = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/copyparty";
      description = "Library that copyparty serves and navidrome and slskd use";
    };
  };
}
