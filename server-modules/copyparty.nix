# copyparty — browser-accessible file server with upload support.
# Reachable over the tailnet only (firewall trusts tailscale0); Caddy on the
# VPS fronts it publicly at https://files.<domain>. The VPS's tailnet address
# must stay listed in --xff-src: without it copyparty distrusts Caddy's
# X-Forwarded-For, bans it, and 403s every public request.
# The whole share is anonymous-read: anyone who reaches files.<domain> can browse
# and download it without logging in. The apex site (server-modules/site.nix)
# hotlinks its gif from here, so anon read must stay on or tek.rip breaks.
# Login passwords live in sops: `sops hosts/vps/secrets/secrets.yaml`
#   copyparty-password        -> milotek (rwmd, full access)
#   copyparty-guest-password  -> guest   (no grant beyond anon read; removable)
#
# Uploads are renamed to lowercase snake_case on arrival by the tidyname xbu
# hook, so the share never accumulates names with spaces or punctuation again.
# reloc only fires over HTTP (up2k/basic/webdav) — fine here, no ftp/tftp/smb.
{
  config,
  pkgs,
  ...
}: let
  tidyname = import ../pkgs/tidyname/package.nix {inherit pkgs;};

  start = pkgs.writeShellScript "copyparty-start" ''
    pw="$(cat ${config.sops.secrets.copyparty-password.path})"
    guest_pw="$(cat ${config.sops.secrets.copyparty-guest-password.path})"
    exec ${pkgs.copyparty}/bin/copyparty \
      -i 0.0.0.0 \
      -p 3923 \
      --rproxy 1 \
      --xff-src 100.117.236.50/32 \
      --daw \
      -a milotek:"$pw" \
      -a guest:"$guest_pw" \
      --xbu j,c1,,${tidyname}/bin/tidyname,hook \
      -v /var/lib/copyparty::r:rwmd,milotek
  '';
in {
  users.users.copyparty = {
    isSystemUser = true;
    group = "copyparty";
  };
  users.groups.copyparty = {};

  sops.secrets.copyparty-password = {
    owner = "copyparty";
    mode = "0400";
  };

  sops.secrets.copyparty-guest-password = {
    owner = "copyparty";
    mode = "0400";
  };

  systemd.services.copyparty = {
    description = "copyparty file server";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      ExecStart = start;
      User = "copyparty";
      Group = "copyparty";
      StateDirectory = "copyparty";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
