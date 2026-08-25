# Adguard is a network-wide ad blocker
# When installed, open localhost:3000 to setup
#
# Bind the LAN and tailnet addresses explicitly, not 0.0.0.0: systemd-resolved
# (enabled by nixos/tailscale.nix) already holds 127.0.0.53:53.
{config, ...}: {
  services.adguardhome = {
    enable = true;
    port = 3000;
  };

  networking.firewall = {
    allowedTCPPorts = [53];
    allowedUDPPorts = [53];
    # Allow containers to reach adguard UI (for glance dns-stats widget)
    extraCommands = ''
      iptables -I INPUT 1 -s 10.233.0.0/16 -p tcp --dport 3000 -j ACCEPT
    '';
    extraStopCommands = ''
      iptables -D INPUT -s 10.233.0.0/16 -p tcp --dport 3000 -j ACCEPT 2>/dev/null || true
    '';
  };
  # Cloudflare Tunnel ingress line stripped: we expose via the VPS caddy over the
  # tailnet, not cloudflared, and config.var.{tunnelId,domain} are unset here.
}
