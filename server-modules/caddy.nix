# Caddy reverse proxy — fronts internal services with automatic HTTPS (Let's Encrypt).
#
# To expose another service, add a vhost below. *.<domain> already wildcards to
# this VPS, so no DNS record is needed.
{config, ...}: let
  minipc = "100.85.180.11";
in {
  services.caddy = {
    enable = true;
    email = config.var.git.email; # Let's Encrypt ACME account / expiry notices

    virtualHosts."files.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:3923
    '';

    virtualHosts."music.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:4533
    '';

    # slskd web UI (Soulseek). Gated by slskd's own login (creds in sops).
    virtualHosts."slsk.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:5030
    '';

    # Home Assistant. Gated by its own onboarding login.
    virtualHosts."home.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:8123
    '';
  };

  # 80 lets Caddy solve the ACME challenge and redirect http -> https; 443 serves the site.
  networking.firewall.allowedTCPPorts = [80 443];
}
