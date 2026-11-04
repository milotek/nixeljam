# Adguard is a network-wide ad blocker
{...}: let
  listenAddress = "100.85.180.11";
  port = 3000;
in {
  services.adguardhome = {
    enable = true;
    inherit port;
    host = listenAddress;

    settings = {
      http.address = "${listenAddress}:${toString port}";

      dns = {
        # Not 0.0.0.0 (resolved holds :53) and not the DHCP LAN address (missing ones stop startup).
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
