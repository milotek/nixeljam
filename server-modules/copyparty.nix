# copyparty — browser-accessible file server with upload support.
# Reachable over the tailnet only (firewall trusts tailscale0); Caddy on the
# VPS fronts it publicly at https://files.<domain>.
#
# The whole volume is anonymously readable: anyone who reaches files.<domain>
# can browse and download everything under /var/lib/copyparty, including the
# music tree Navidrome and slskd write into. Writes still require the milotek
# login. To take it private again, drop the leading `:r` from the -v line.
#
# Login password lives in sops: `sops hosts/minipc/secrets/system-secrets.yaml`
#   copyparty-password  -> milotek (rwmd, full access)
# That same password is shared with slskd, navidrome and tunedeck, so rotating
# it means rotating those too.
#
# --xff-src trusts the VPS's tailnet address so copyparty honours Caddy's
# X-Forwarded-Proto. Without it copyparty assumes plain http and rejects every
# browser POST (login, upload, rename) as a cross-origin request, because the
# Origin the browser sends is https.
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
    exec ${pkgs.copyparty}/bin/copyparty \
      -i 0.0.0.0 \
      -p 3923 \
      --rproxy 1 \
      --xff-src 100.117.236.50/32 \
      --daw \
      --no-robots \
      -a milotek:"$pw" \
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
