# Adguard is a network-wide ad blocker, reachable at http://minipc:3000 over
# tailscale.
#
# Tailnet-only, and so unauthenticated, on the same trust model as glance.
# Without a declarative `settings` block AdGuard never leaves its first-run
# install wizard: it serves /install.html on the web port and binds no DNS
# listener at all, so nothing pointed at it resolves.
#
# bind_hosts is the tailnet address rather than 0.0.0.0 because systemd-resolved
# (enabled by nixos/tailscale.nix) already holds 127.0.0.53:53. The LAN address
# is deliberately absent — it comes from DHCP, and AdGuard refuses to start if
# an address in bind_hosts is missing.
{...}: let
  listenAddress = "100.85.180.11"; # minipc's tailnet address
  port = 3000;
in {
  services.adguardhome = {
    enable = true;
    inherit port;
    host = listenAddress;

    settings = {
      http.address = "${listenAddress}:${toString port}";

      dns = {
        bind_hosts = [listenAddress];
        bootstrap_dns = ["1.1.1.1" "9.9.9.10"];
        upstream_dns = ["https://dns.cloudflare.com/dns-query" "https://dns.quad9.net/dns-query"];
      };

      filters = [
        {
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          id = 1;
          enabled = true;
        }
        {
          name = "AdAway Default Blocklist";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
          id = 2;
          enabled = true;
        }
      ];
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [53 port];
  networking.firewall.interfaces.tailscale0.allowedUDPPorts = [53];
}
