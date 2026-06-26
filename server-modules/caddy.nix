# Caddy reverse proxy — fronts internal services with automatic HTTPS (Let's Encrypt).
#
# To expose another service: give it a subdomain that proxies to its localhost
# port below, point an A record <name>.<domain> -> VPS public IP, and make sure
# 80/443 are open both here and in the Oracle Cloud security list.
{config, ...}: {
  services.caddy = {
    enable = true;
    email = config.var.git.email; # Let's Encrypt ACME account / expiry notices

    virtualHosts."files.${config.var.domain}".extraConfig = ''
      reverse_proxy localhost:3923
    '';
  };

  # 80 lets Caddy solve the ACME challenge and redirect http -> https; 443 serves the site.
  networking.firewall.allowedTCPPorts = [80 443];
}
