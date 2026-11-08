{
  config,
  pkgs,
  ...
}: let
  minipc = "100.85.180.11";

  robots = pkgs.writeTextDir "robots.txt" ''
    User-agent: Discordbot
    Allow: /

    User-agent: *
    Disallow: /
  '';
in {
  services.caddy = {
    enable = true;
    email = config.var.git.email;

    virtualHosts."${config.var.domain}" = {
      serverAliases = ["www.${config.var.domain}"];
      extraConfig = ''
        reverse_proxy ${minipc}:8090
      '';
    };

    virtualHosts."milo.${config.var.domain}".extraConfig = ''
      redir https://files.${config.var.domain}/Pictures/Art/creations/more_skittles_more_leetcode.jpg
    '';

    virtualHosts."files.${config.var.domain}".extraConfig = ''
      @crawlers header_regexp User-Agent "(?i)(amazonbot|applebot|bytespider|ccbot|claudebot|diffbot|googlebot|gptbot|imagesiftbot|meta-externalagent|oai-searchbot|omgili|perplexitybot|youbot)"
      @scanners header_regexp User-Agent "(?i)(censys|cms-scanner|expanse|l9scan|leakix|masscan|nuclei|paloaltonetworks|python-httpx|python-requests|scrapy|shodan|visionheight|vuln_scanner|wpbot|zgrab)"

      # Must stay ahead of the 403s: a 4xx on robots.txt means "crawl anything" (RFC 9309).
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

    virtualHosts."slsk.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:5030
    '';

    virtualHosts."home.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:8123
    '';

    virtualHosts."dash.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:5678
    '';

    virtualHosts."habits.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:8095
    '';

    # Never add a Pelican vhost: panel admin is root on the minipc.

    virtualHosts."term.minipc.${config.var.domain}".extraConfig = ''
      reverse_proxy ${minipc}:8082
    '';
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
