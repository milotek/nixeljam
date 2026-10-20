{
  config,
  lib,
  pkgs,
  ...
}: let
  tidyname = import ../pkgs/tidyname/package.nix {inherit pkgs;};

  friendsDir = "/var/lib/copyparty/Friends";

  secret = name: config.sops.secrets.${name}.path;

  start = pkgs.writeShellScript "copyparty-start" ''
    exec ${pkgs.copyparty}/bin/copyparty \
      -i 0.0.0.0 \
      -p 3923 \
      --rproxy 1 \
      --xff-src 100.117.236.50/32 \
      --daw \
      -a milotek:"$(cat ${secret "copyparty-password"})" \
      -a guest:"$(cat ${secret "copyparty-guest-password"})" \
      -a tmkcell:"$(cat ${secret "copyparty-tmkcell-password"})" \
      --xbu j,c1,,${tidyname}/bin/tidyname,hook \
      -v /var/lib/copyparty::r:rwmd,milotek:c,unlist='^lost.found/?$' \
      -v ${friendsDir}/tmkcell:Friends/tmkcell:r:rwmd,tmkcell:rwmd,milotek
  '';
in {
  users.users.copyparty = {
    isSystemUser = true;
    group = "copyparty";
  };
  users.groups.copyparty = {};

  sops.secrets = lib.genAttrs [
    "copyparty-password"
    "copyparty-guest-password"
    "copyparty-tmkcell-password"
  ] (_: {
    owner = "copyparty";
    mode = "0400";
  });

  systemd.tmpfiles.rules = [
    "d ${friendsDir} 0755 copyparty copyparty - -"
    "d ${friendsDir}/tmkcell 0755 copyparty copyparty - -"
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
