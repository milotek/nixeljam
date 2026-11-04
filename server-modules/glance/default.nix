{...}: let
  port = 5678;
  listenAddress = "100.85.180.11";
in {
  imports = [./pages.nix];

  services.glance = {
    enable = true;

    settings.server = {
      host = listenAddress;
      inherit port;
      proxied = true;
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [port];
}
