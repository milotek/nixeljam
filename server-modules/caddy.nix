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

    # The apex: a one-page static site (server-modules/site.nix) on the minipc.
    virtualHosts."${config.var.domain}" = {
      serverAliases = ["www.${config.var.domain}"];
      extraConfig = ''
        reverse_proxy ${minipc}:8090
      '';
    };

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

    # Glance dashboard. No authentication in front of it — see
    # server-modules/glance/default.nix.
    virtualHosts."dash.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:5678
    '';

    # Habit tracker. Deliberately unauthenticated: the wall display has to
    # render without a login, so POST /tick is world-callable too. The only
    # thing behind it is a habit log.
    virtualHosts."habits.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:8095
    '';

    # The Pelican panel and its wings daemon are deliberately absent: panel
    # admin is arbitrary root code execution on the minipc (wings runs as root
    # on the Docker socket), so both stay tailnet-only. Game traffic itself
    # still reaches players through game-relay.nix, which needs no vhost.

    # minipc's terminal sessions in a browser. Nested under the machine name
    # because this is the one service that is genuinely per-host; the singletons
    # above stay flat so they can move machines without breaking their URL.
    #
    # A zellij login token is the only thing between this and a root-capable
    # shell — see server-modules/zellij-web.nix.
    virtualHosts."term.minipc.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:8082
    '';
  };

  # 80 lets Caddy solve the ACME challenge and redirect http -> https; 443 serves the site.
  networking.firewall.allowedTCPPorts = [80 443];
}
