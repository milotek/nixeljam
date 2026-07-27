# copyparty — browser-accessible file server with upload support.
# Bound to localhost; exposed publicly via the Caddy reverse proxy (caddy.nix)
# at https://files.<domain>. No firewall port is opened here.
# The login password lives in sops: `sops hosts/vps/secrets/secrets.yaml` -> copyparty-password
{
  config,
  pkgs,
  ...
}: let
  start = pkgs.writeShellScript "copyparty-start" ''
    pw="$(cat ${config.sops.secrets.copyparty-password.path})"
    exec ${pkgs.copyparty}/bin/copyparty \
      -i 127.0.0.1 \
      -p 3923 \
      --rproxy 1 \
      -a milotek:"$pw" \
      -v /var/lib/copyparty::rwmd,milotek
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
