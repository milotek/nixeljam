{aspects, ...}: {
  flake.modules.nixos.slskd = {config, ...}: let
    root = config.nixeljam.media;
    username = config.nixeljam.username;
    password = config.sops.placeholder."copyparty/${username}";
  in {
    imports = [
      aspects.media
      aspects.secrets
    ];

    services.slskd = {
      enable = true;
      domain = null;
      openFirewall = true;
      environmentFile = config.sops.templates.slskd-env.path;
      settings = {
        soulseek.description = "slskd";
        directories.downloads = "${root}/Music/Songs/Soulseek";
        shares.directories = ["${root}/Music/Songs"];
      };
    };

    systemd.services.slskd.unitConfig.RequiresMountsFor = [root];

    sops.secrets."copyparty/${username}" = {};

    sops.templates.slskd-env = {
      owner = "slskd";
      content = ''
        SLSKD_SLSK_USERNAME=${username}
        SLSKD_SLSK_PASSWORD=${password}
        SLSKD_USERNAME=${username}
        SLSKD_PASSWORD=${password}
      '';
    };
  };
}
