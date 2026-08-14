# slskd — headless Soulseek daemon with a web UI.
# Bound to localhost:5030; exposed publicly via the VPS Caddy reverse proxy
# (caddy.nix) at https://slsk.<domain>, tunnelled up by the reverse tunnel.
#
# Downloads land in copyparty's Music/Songs/Soulseek, so Navidrome scans them
# and they show up in arpeggi automatically. Shares Music/Songs read-only so
# we're a legit sharer on the network, not a blocked leecher.
#
# Uses the shared creds (milotek / the copyparty-password secret) for both the
# web UI login and the Soulseek network account — same user+pass as every other
# self-hosted service. No new secret needed; the env file is rendered from the
# existing `copyparty-password` sops secret at activation.
{config, ...}: let
  downloads = "/var/lib/copyparty/Music/Songs/Soulseek";
  shareRoot = "/var/lib/copyparty/Music/Songs";
  user = config.var.username;
in {
  services.slskd = {
    enable = true;
    domain = null; # use Caddy (caddy.nix), not the module's built-in nginx vhost
    openFirewall = true; # opens the soulseek p2p listen port (not the web ui)
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

  # Download target must be writable by slskd but readable by copyparty (serves
  # it) and navidrome (scans it) — 0755, owned by slskd.
  systemd.tmpfiles.rules = [
    "d ${downloads} 0755 slskd slskd - -"
  ];

  # Render the env file from the shared password secret (copyparty-password,
  # declared in copyparty.nix). Same milotek/<shared-pass> as everything else.
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
