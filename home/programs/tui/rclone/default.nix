# Mounts files.tek.rip (the copyparty file server) as an always-on drive at
# ~/files over WebDAV, via a systemd user service. The login password is read
# at runtime from the sops secret `copyparty-password` (see ../../hosts/pc/secrets),
# obscured for rclone, and never written to the store.
{
  config,
  pkgs,
  lib,
  ...
}: let
  mountPoint = "${config.home.homeDirectory}/files";

  mount = pkgs.writeShellScript "rclone-copyparty-mount" ''
    set -euo pipefail
    pass="$(${pkgs.rclone}/bin/rclone obscure "$(cat ${config.sops.secrets.copyparty-password.path})")"
    exec ${pkgs.rclone}/bin/rclone mount :webdav: ${mountPoint} \
      --webdav-url "https://files.tek.rip" \
      --webdav-vendor other \
      --webdav-user milotek \
      --webdav-pass "$pass" \
      --vfs-cache-mode writes \
      --dir-cache-time 30s \
      --umask 077
  '';
in {
  home.packages = [pkgs.rclone];

  systemd.user.services.rclone-copyparty = {
    Unit = {
      Description = "rclone mount of files.tek.rip (copyparty WebDAV)";
      After = ["sops-nix.service" "network-online.target"];
      Wants = ["sops-nix.service" "network-online.target"];
    };
    Service = {
      Type = "notify";
      Environment = ["PATH=${lib.makeBinPath [pkgs.fuse3]}"];
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";
      ExecStart = "${mount}";
      ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${mountPoint}";
      Restart = "on-failure";
      RestartSec = "10";
    };
    Install.WantedBy = ["default.target"];
  };
}
