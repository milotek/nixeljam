# Tailscale — private WireGuard mesh across all my machines.
#
# It carries everything now, not just admin access: the VPS's caddy reaches
# minipc's services over it, and it is the only way in to any host.
#
# One-time per host: `sudo tailscale up`, then approve the device in the admin
# console. Headless hosts print a login URL to open from any browser.
{
  config,
  lib,
  ...
}: let
  # Static because MagicDNS is off below, and a device keeps its 100.x address.
  tailnet = {
    pc = "100.96.10.65";
    minipc = "100.85.180.11";
    vps = "100.117.236.50";
  };
in {
  services.tailscale.enable = true;

  networking.hosts =
    lib.mapAttrs' (name: ip: lib.nameValuePair ip [name])
    (lib.filterAttrs (name: _: name != config.var.hostname) tailnet);

  networking.firewall = {
    # Trust the tailnet interface so my own devices can reach local services
    # (sshd, etc.) over Tailscale without per-port firewall rules.
    trustedInterfaces = ["tailscale0"];
    # Open the WireGuard port for direct peer connections (falls back to DERP
    # relays if closed — this just keeps things fast).
    allowedUDPPorts = [config.services.tailscale.port];
  };
}
