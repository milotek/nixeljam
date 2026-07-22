# Dials the VPS and exposes this host's sshd there on <remotePort>, so
# `ssh -p <remotePort> milotek@tek.rip` reaches it. Key lives in a system sops
# secret so the tunnel comes up at boot without a login.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.reverseTunnel;
in {
  options.custom.reverseTunnel = {
    enable = lib.mkEnableOption "reverse SSH tunnel to the VPS";
    remotePort = lib.mkOption {
      type = lib.types.port;
      description = "Port the VPS exposes for this host (unique per host).";
    };
    sopsFile = lib.mkOption {
      type = lib.types.path;
      description = "sops file providing the `reverse-tunnel-key` secret.";
    };
    remote = lib.mkOption {
      type = lib.types.str;
      default = "milotek@tek.rip";
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      secrets."reverse-tunnel-key".sopsFile = cfg.sopsFile;
    };

    systemd.services.vps-reverse-tunnel = {
      description = "Reverse SSH tunnel to the VPS";
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
            -R *:${toString cfg.remotePort}:localhost:22 \
            ${cfg.remote}
        '';
      };
    };
  };
}
