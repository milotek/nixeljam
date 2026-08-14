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

    virtualHosts."music.${config.var.domain}".extraConfig = ''
      reverse_proxy localhost:4533
    '';

    # slskd web UI (Soulseek). Gated by slskd's own login (creds in sops).
    virtualHosts."slsk.${config.var.domain}".extraConfig = ''
      reverse_proxy localhost:5030
    '';

    # Home Assistant. Gated by its own onboarding login.
    virtualHosts."home.${config.var.domain}".extraConfig = ''
      reverse_proxy localhost:8123
    '';

    # PC's desktop: noVNC is tunnelled up to localhost:6080 by the PC's reverse
    # tunnel. This port is public, so gate it behind basic auth (the VNC side
    # itself is unauthenticated but only reachable via this tunnel).
    #
    # Regenerate the hash to change the password:
    #   mkpasswd -m bcrypt -R 14 'yourpassword'
    virtualHosts."remote.pc.${config.var.domain}".extraConfig = ''
      basic_auth {
        milotek $2b$14$6JMWyRdzROc3BeBMr3hD0OmV/MTQxKt8ZQRVvoMyZsErH/MlwC0GW
      }
      redir / /vnc.html
      reverse_proxy localhost:6080
    '';
  };

  # 80 lets Caddy solve the ACME challenge and redirect http -> https; 443 serves the site.
  networking.firewall.allowedTCPPorts = [80 443];
}
