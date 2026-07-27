# Dials the VPS over an *outbound* SSH connection and asks it to expose this
# host's local ports there (ssh -R), so services on this box are reachable via
# the VPS with no inbound port-forwarding at home. The key lives in a system
# sops secret so the tunnels come up at boot without a login.
#
# Each forward maps a port the VPS binds -> a port on this host:
#   remoteBind:remotePort  (on the VPS)  ->  localHost:localPort  (here)
# Use remoteBind = "*" for a publicly reachable port (needs GatewayPorts, an
# open firewall port, and a matching permitlisten on the VPS key), or
# "localhost" for a private port that something on the VPS (e.g. caddy) fronts.
#
# Each forward runs as its own systemd service, so a misconfigured forward can
# only take down itself - the SSH lifeline stays up independently.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.reverseTunnel;
in {
  options.custom.reverseTunnel = {
    enable = lib.mkEnableOption "reverse SSH tunnel(s) to the VPS";
    remote = lib.mkOption {
      type = lib.types.str;
      default = "${config.var.username}@tek.rip";
      description = "user@host of the VPS to dial.";
    };
    sopsFile = lib.mkOption {
      type = lib.types.path;
      description = "sops file providing the `reverse-tunnel-key` secret.";
    };
    forwards = lib.mkOption {
      description = "Ports the VPS exposes on this host's behalf.";
      default = [];
      type = lib.types.listOf (lib.types.submodule {
        options = {
          remoteBind = lib.mkOption {
            type = lib.types.str;
            default = "*";
            description = ''Bind address on the VPS: "*" (public) or "localhost" (private).'';
          };
          remotePort = lib.mkOption {
            type = lib.types.port;
            description = "Port the VPS listens on (unique per host).";
          };
          localHost = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            description = "Host on this side to forward to.";
          };
          localPort = lib.mkOption {
            type = lib.types.port;
            description = "Port on this side to forward to.";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      secrets."reverse-tunnel-key".sopsFile = cfg.sopsFile;
    };

    systemd.services = lib.listToAttrs (map (f:
      lib.nameValuePair "vps-reverse-tunnel-${toString f.remotePort}" {
        description = "Reverse SSH tunnel to the VPS (VPS:${toString f.remotePort} -> ${f.localHost}:${toString f.localPort})";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          Restart = "always";
          RestartSec = 10;
          StateDirectory = "vps-reverse-tunnel";
          ExecStart = ''
            ${pkgs.openssh}/bin/ssh -NT \
              -o BatchMode=yes \
              -o ServerAliveInterval=30 \
              -o ServerAliveCountMax=3 \
              -o ExitOnForwardFailure=yes \
              -o StrictHostKeyChecking=accept-new \
              -o UserKnownHostsFile=/var/lib/vps-reverse-tunnel/known_hosts \
              -i ${config.sops.secrets."reverse-tunnel-key".path} \
              -R ${f.remoteBind}:${toString f.remotePort}:${f.localHost}:${toString f.localPort} \
              ${cfg.remote}
          '';
        };
      })
    cfg.forwards);
  };
}
