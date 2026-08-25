# Tailscale — private WireGuard mesh across all my machines.
#
# It carries everything now, not just admin access: the VPS's caddy reaches
# minipc's services over it, and it is the only way in to any host.
#
# One-time per host: `sudo tailscale up`, then approve the device in the admin
# console. Headless hosts print a login URL to open from any browser.
{config, ...}: {
  services.tailscale.enable = true;

  services.tailscale.extraSetFlags = ["--accept-dns=true"];

  # Not optional: with plain resolvconf, tailscaled claims all of resolv.conf,
  # so losing it loses DNS entirely. resolved routes only ts.net to the tailnet.
  services.resolved.enable = true;

  networking.firewall = {
    # Trust the tailnet interface so my own devices can reach local services
    # (sshd, etc.) over Tailscale without per-port firewall rules.
    trustedInterfaces = ["tailscale0"];
    # Open the WireGuard port for direct peer connections (falls back to DERP
    # relays if closed — this just keeps things fast).
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
