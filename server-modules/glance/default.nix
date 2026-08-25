# Glance dashboard for minipc's self-hosted services.
#
# Tailnet-only on purpose: the Minecraft power button carries its bearer token
# in the rendered page source, so anyone who can load this page can stop the
# server. Reach it at http://minipc:5678 over tailscale.
#
# The colour scheme comes from stylix's own glance target, so there is nothing
# to configure here beyond the bind address.
{config, ...}: let
  port = 5678;
  listenAddress = "100.85.180.11"; # minipc's tailnet address
in {
  imports = [./pages.nix];

  # glance runs under DynamicUser, so it cannot be added to a group that can
  # read the sops secret. Rendering the token into an env file instead lets
  # systemd read it as root and hand it over as an environment variable.
  sops.templates."glance.env".content = ''
    MC_API_KEY=${config.sops.placeholder.minecraft-api-key}
  '';

  services.glance = {
    enable = true;
    environmentFile = config.sops.templates."glance.env".path;

    settings.server = {
      host = listenAddress;
      inherit port;
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [port];
}
