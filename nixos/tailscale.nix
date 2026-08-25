# Tailscale — private WireGuard mesh across all my machines.
#
# Purpose: an out-of-band admin door that does NOT depend on this host's own DNS
# (AdGuard on the minipc) or the tek.rip reverse tunnel. tailscaled reaches its
# control plane via its own bootstrap DNS, so even a rebuild that breaks local
# DNS can't lock me out — I can still SSH in over the tailnet. See the minipc
# lockout incident that motivated this.
#
# One-time per host after the first rebuild, run interactively:
#   sudo tailscale up
# It prints a login URL; approve the device in the Tailscale admin console.
# On headless hosts (vps, server) just open the printed URL from any browser.
{config, ...}: {
  services.tailscale.enable = true;

  # Not extraUpFlags: that only runs via tailscaled-autoconnect, which needs an
  # authKeyFile these hosts don't use.
  services.tailscale.extraSetFlags = ["--accept-dns=false"];

  networking.firewall = {
    # Trust the tailnet interface so my own devices can reach local services
    # (sshd, etc.) over Tailscale without per-port firewall rules.
    trustedInterfaces = ["tailscale0"];
    # Open the WireGuard port for direct peer connections (falls back to DERP
    # relays if closed — this just keeps things fast).
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
