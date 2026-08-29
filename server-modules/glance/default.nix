# Glance dashboard for minipc's self-hosted services.
#
# Tailnet-only; reach it at http://minipc:5678 over tailscale.
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
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [port];
}
