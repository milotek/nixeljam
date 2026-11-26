{config, ...}: let
  inherit (config.flake.lib) tailnet;
in {
  flake.modules.nixos.caddy = let
    domain = tailnet.domain;
    proxy = port: "reverse_proxy ${tailnet.hosts.minipc}:${toString port}";
  in {
    services.caddy = {
      enable = true;
      openFirewall = true;

      virtualHosts = {
        ${domain} = {
          serverAliases = ["www.${domain}"];
          extraConfig = proxy 8090;
        };

        "milo.${domain}".extraConfig = ''
          redir https://files.${domain}/Pictures/Art/creations/more_skittles_more_leetcode.jpg
        '';

        "files.${domain}".extraConfig = proxy 3923;
        "music.${domain}".extraConfig = proxy 4533;
        "slsk.${domain}".extraConfig = proxy 5030;
        "home.${domain}".extraConfig = proxy 8123;
        "dash.${domain}".extraConfig = proxy 5678;
        "habits.${domain}".extraConfig = proxy 8095;
        "term.minipc.${domain}".extraConfig = proxy 8082;
      };
    };
  };
}
