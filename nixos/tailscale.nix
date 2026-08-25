# Tailscale — private WireGuard mesh across all my machines.
#
# It carries everything now, not just admin access: the VPS's caddy reaches
# minipc's services over it, and it is the only way in to any host.
#
# One-time per host: `sudo tailscale up`, then approve the device in the admin
# console. Headless hosts print a login URL to open from any browser.
{config, ...}: {
  services.tailscale.enable = true;

  # MagicDNS, so peers resolve by bare name (`ssh vps`).
  services.tailscale.extraSetFlags = ["--accept-dns=true"];

  # Without resolved, tailscaled points all of /etc/resolv.conf at itself, so a
  # dead tailscaled means no DNS at all - that is what took minipc down before.
  # resolved gets split DNS instead: only ts.net goes to the tailnet resolver.
  #
  # NOTE: the stub listener holds 127.0.0.53:53, so AdGuard must bind its
  # LAN/tailnet addresses explicitly rather than the wildcard.
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
