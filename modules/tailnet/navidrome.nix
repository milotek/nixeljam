{aspects, ...}: {
  flake.modules.nixos.navidrome = {config, ...}: let
    root = config.nixeljam.media;
  in {
    imports = [aspects.media];

    services.navidrome = {
      enable = true;
      settings = {
        MusicFolder = "${root}/Music";
        Address = "0.0.0.0";
      };
    };

    systemd.services.navidrome.unitConfig.RequiresMountsFor = [root];
  };
}
