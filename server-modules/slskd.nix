{config, ...}: let
  downloads = "/var/lib/copyparty/Music/Songs/Soulseek";
  shareRoot = "/var/lib/copyparty/Music/Songs";
  user = config.var.username;
in {
  services.slskd = {
    enable = true;
    domain = null;
    openFirewall = true;
    environmentFile = config.sops.templates."slskd-env".path;
    settings = {
      web.port = 5030;
      soulseek = {
        description = "slskd";
        listen_port = 50300;
      };
      directories.downloads = downloads;
      shares.directories = [shareRoot];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${downloads} 0755 slskd slskd - -"
  ];

  sops.templates."slskd-env" = {
    owner = "slskd";
    mode = "0400";
    content = ''
      SLSKD_SLSK_USERNAME=${user}
      SLSKD_SLSK_PASSWORD=${config.sops.placeholder."copyparty-password"}
      SLSKD_USERNAME=${user}
      SLSKD_PASSWORD=${config.sops.placeholder."copyparty-password"}
    '';
  };
}
