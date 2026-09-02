# Habit tracker rendered as a GitHub-style activity grid, for a wall-mounted
# kiosk. Source and NixOS module live in github:milotek/habits.
#
# /var/lib/habits is bind-mounted from the host: the SQLite database is the only
# state here that cannot be rebuilt from source, so it stays outside the
# container and is the one thing worth backing up.
#
# No authentication, by choice - see the vhost comment in caddy.nix.
{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (import ./mk-container.nix {inherit lib config;}) mkContainer;
in {
  imports = [
    (mkContainer {
      name = "habits";
      hostIp = "10.233.12.1";
      containerIp = "10.233.12.2";
      bindMounts."/var/lib/habits" = {
        hostPath = "/var/lib/habits";
        isReadOnly = false;
      };
      nixosConfig = {lib, ...}: {
        imports = [inputs.habits.nixosModules.default];

        users.users.habits.uid = lib.mkForce 979;
        users.groups.habits.gid = lib.mkForce 969;

        services.habits = {
          enable = true;
          port = 8095;
          openFirewall = true;
        };

        system.stateVersion = "24.05";
      };
    })
  ];

  # Caddy on the VPS dials this host's tailscale address, so the container's
  # private network needs a way in. The cloudflared services reach their
  # containers directly by IP and need no equivalent.
  containers.habits.forwardPorts = [
    {
      containerPort = 8095;
      hostPort = 8095;
      protocol = "tcp";
    }
  ];

  users.users.habits = {
    isSystemUser = true;
    group = "habits";
    uid = 979;
  };
  users.groups.habits.gid = 969;

  systemd.tmpfiles.rules = [
    "d /var/lib/habits 0750 habits habits -"
  ];
}
