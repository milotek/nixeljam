{
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) tailnet;
in {
  flake.modules.nixos.dashboard = {config, ...}: let
    host = config.networking.hostName;
    address = tailnet.hosts.${host};
    site = title: url: icon: {inherit title url icon;};
    public = name: "https://${name}.${tailnet.domain}";
  in {
    imports = [
      aspects.tailnet
      aspects.theme
    ];

    services.glance = {
      enable = true;
      settings = {
        server = {
          host = address;
          port = 5678;
          proxied = true;
        };
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "server-stats";
                    servers = [
                      {
                        type = "local";
                        name = host;
                      }
                    ];
                  }
                  {
                    type = "monitor";
                    title = "Services";
                    cache = "1m";
                    sites = [
                      (site "AdGuard" "http://${address}:3000" "sh:adguard-home")
                      (site "Files" (public "files") "sh:copyparty")
                      (site "Music" (public "music") "sh:navidrome")
                      (site "Soulseek" (public "slsk") "sh:soulseek")
                      (site "Home Assistant" (public "home") "sh:home-assistant")
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
