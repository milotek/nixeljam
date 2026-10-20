{
  config,
  lib,
  pkgs,
  ...
}: let
  tidyname = import ../pkgs/tidyname/package.nix {inherit pkgs;};

  root = "/var/lib/copyparty";

  secrets = {
    milotek = "copyparty-password";
    guest = "copyparty-guest-password";
    friend = "copyparty-friend-password";
    bros = "copyparty-bros-password";
  };

  accounts = lib.concatStringsSep " \\\n      " (lib.mapAttrsToList (
      user: name: ''-a ${user}:"$(cat ${config.sops.secrets.${name}.path})"''
    )
    secrets);

  start = pkgs.writeShellScript "copyparty-start" ''
    exec ${pkgs.copyparty}/bin/copyparty \
      -i 0.0.0.0 \
      -p 3923 \
      --rproxy 1 \
      --xff-src 100.117.236.50/32 \
      --daw \
      ${accounts} \
      --xbu j,c1,,${tidyname}/bin/tidyname,hook \
      -v ${root}::r:rwmd,bros:A,milotek:c,unlist='^lost.found/?$' \
      -v ${root}/Downloads:Downloads:r:rwm,friend:rwmd,bros:A,milotek
  '';
in {
  users.users.copyparty = {
    isSystemUser = true;
    group = "copyparty";
  };
  users.groups.copyparty = {};

  sops.secrets = lib.genAttrs (lib.attrValues secrets) (_: {
    owner = "copyparty";
    mode = "0400";
  });

  systemd.tmpfiles.rules = [
    "d ${root}/Downloads 0755 copyparty copyparty - -"
  ];

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
