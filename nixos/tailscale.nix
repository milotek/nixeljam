{config, ...}: {
  services.tailscale.enable = true;

  services.tailscale.extraSetFlags = ["--accept-dns=true"];

  # Required: without resolved, tailscaled takes over resolv.conf and DNS breaks.
  services.resolved.enable = true;

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
