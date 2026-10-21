{
  config,
  pkgs,
  ...
}: let
  tidyname = import ../pkgs/tidyname/package.nix {inherit pkgs;};

  root = "/var/lib/copyparty";

  upload-log = pkgs.writeShellScript "copyparty-upload-log" ''
    user=$(${pkgs.jq}/bin/jq -r .user <<<"$1")
    vp=$(${pkgs.jq}/bin/jq -r .vp <<<"$1")
    sz=$(${pkgs.jq}/bin/jq -r .sz <<<"$1")
    [ "$user" = milotek ] && exit 0
    case "$vp" in
      Downloads/*) ;;
      *) exit 0 ;;
    esac
    ${pkgs.util-linux}/bin/logger -t copyparty-upload "user=$user path=$vp size=$sz"
  '';

  start = pkgs.writeShellScript "copyparty-start" ''
    exec ${pkgs.copyparty}/bin/copyparty \
      -i 0.0.0.0 \
      -p 3923 \
      --rproxy 1 \
      --xff-src 100.117.236.50/32 \
      --daw \
      -a guest:"$(cat ${config.sops.secrets.copyparty-guest-password.path})" \
      -a friend:"$(cat ${config.sops.secrets.copyparty-friend-password.path})" \
      -a bros:"$(cat ${config.sops.secrets.copyparty-bros-password.path})" \
      -a milotek:"$(cat ${config.sops.secrets.copyparty-password.path})" \
      --xbu j,c1,,${tidyname}/bin/tidyname,hook \
      --xau j,${upload-log} \
      -v ${root}::g:r,guest,friend:rwmd,bros:A,milotek:c,unlist='^lost.found/?$' \
      -v ${root}/Downloads:Downloads:r,guest:rwm,friend:rwmd,bros:A,milotek \
      -v ${root}/Music/Songs/Singles:Music/Songs/Singles:r:rwmd,bros:A,milotek
  '';
in {
  users.users.copyparty = {
    isSystemUser = true;
    group = "copyparty";
  };
  users.groups.copyparty = {};

  sops.secrets = {
    copyparty-password = {
      owner = "copyparty";
      mode = "0400";
    };
    copyparty-guest-password = {
      owner = "copyparty";
      mode = "0400";
    };
    copyparty-friend-password = {
      owner = "copyparty";
      mode = "0400";
    };
    copyparty-bros-password = {
      owner = "copyparty";
      mode = "0400";
    };
  };

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
