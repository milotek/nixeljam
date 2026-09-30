# Caddy reverse proxy — fronts internal services with automatic HTTPS (Let's Encrypt).
#
# To expose another service, add a vhost below. *.<domain> already wildcards to
# this VPS, so no DNS record is needed.
{
  config,
  pkgs,
  ...
}: let
  minipc = "100.85.180.11";

  # Discordbot is exempted because it reads robots.txt before rendering a link
  # preview, and pasting a file link into chat should still show the thumbnail.
  robots = pkgs.writeTextDir "robots.txt" ''
    User-agent: Discordbot
    Allow: /

    User-agent: *
    Disallow: /
  '';
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

    # A vanity link to hand out. 302 rather than 301 so the target can be
    # repointed later without fighting browser caches.
    virtualHosts."milo.${config.var.domain}".extraConfig = ''
      redir https://files.${config.var.domain}/Pictures/Art/creations/more_skittles_more_leetcode.jpg
    '';

    virtualHosts."files.${config.var.domain}".extraConfig = ''
      @crawlers header_regexp User-Agent "(?i)(amazonbot|applebot|bytespider|ccbot|claudebot|diffbot|googlebot|gptbot|imagesiftbot|meta-externalagent|oai-searchbot|omgili|perplexitybot|youbot)"
      @scanners header_regexp User-Agent "(?i)(censys|cms-scanner|expanse|l9scan|leakix|masscan|nuclei|paloaltonetworks|python-httpx|python-requests|scrapy|shodan|visionheight|vuln_scanner|wpbot|zgrab)"

      # Ahead of the 403s on purpose: RFC 9309 lets a crawler that gets a 4xx on
      # robots.txt treat the whole site as fair game.
      handle /robots.txt {
        root * ${robots}
        file_server
      }

      handle @crawlers {
        respond 403
      }

      handle @scanners {
        respond 403
      }

      handle {
        header X-Robots-Tag "noindex, nofollow, noarchive, noai, noimageai"
        reverse_proxy ${minipc}:3923
      }
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
