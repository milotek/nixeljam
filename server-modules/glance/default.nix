# Glance dashboard for minipc's self-hosted services.
#
# Binds the tailnet address; caddy on the VPS fronts it publicly at
# https://dash.<domain>. There is no authentication in front of it yet — the
# page exposes the service inventory, their up/down state, and minipc's
# CPU/RAM/disk. Put it behind the SSO proxy when one lands.
#
# The colour scheme comes from stylix's own glance target, so there is nothing
# to configure here beyond the bind address.
{...}: let
  port = 5678;
  listenAddress = "100.85.180.11"; # minipc's tailnet address
in {
  imports = [./pages.nix];

  services.glance = {
    enable = true;

    settings.server = {
      host = listenAddress;
      inherit port;
      # Requests arrive from caddy, so the peer address is always the VPS.
      proxied = true;
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [port];
}
