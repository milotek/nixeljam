# Cloudflared tunnel configuration for NixOS
# It allows exposing services securely via Cloudflare Tunnel
{aspects, ...}: {
  flake.modules.nixos.cloudflared = {
    config,
    lib,
    pkgs,
    ...
  }: let
    tunnelId = config.nixeljam.server.tunnelId;
  in {
    imports = [aspects.common];

    options.nixeljam.server = {
      domain = lib.mkOption {
        type = lib.types.str;
        description = "Domain the services are exposed on, as <service>.<domain>";
      };
      tunnelId = lib.mkOption {
        type = lib.types.str;
        description = "Cloudflare tunnel exposing the services";
      };
    };

    config = {
      sops.secrets.cloudflared-token.mode = "0400";

      # To setup cloudflared, run:
      # - `cloudflared tunnel login`
      # - `cloudflared tunnel create YourTunnelName`
      #
      # This will create a credentials file & give you the tunnel ID to use below.
      services.cloudflared = {
        enable = true;
        tunnels."${tunnelId}" = {
          credentialsFile = config.sops.secrets."cloudflared-token".path;
          default = "http_status:404";
        };
      };

      environment.systemPackages = with pkgs.unstable; [
        cloudflared
      ];

      systemd.services."cloudflared-tunnel-${tunnelId}" = {
        wantedBy = ["multi-user.target"];
        after = ["network-online.target" "adguardhome.service"];
        wants = ["network-online.target"];
        requires = ["adguardhome.service"];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "5s";
          StartLimitIntervalSec = 300;
          StartLimitBurst = 10;
        };
      };

      # At the moment (2025), for support of browser rendering of the tunnels, this line is required:
      services.openssh.settings.Macs = [
        "hmac-sha2-256"
        "hmac-sha2-512"
      ];
    };
  };
}
