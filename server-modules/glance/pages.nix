{config, ...}: let
  domain = config.var.domain;
in {
  services.glance.settings.pages = [
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
                  name = "minipc";
                }
              ];
            }

            {
              type = "monitor";
              title = "Services";
              cache = "1m";
              sites = [
                {
                  # AdGuard has no caddy vhost, so this link only resolves for a
                  # viewer on the tailnet. The up/down dot still works for everyone.
                  title = "AdGuard";
                  url = "http://100.85.180.11:3000";
                  icon = "sh:adguard-home";
                }
                {
                  title = "Files";
                  url = "https://files.${domain}";
                  icon = "sh:copyparty";
                }
                {
                  title = "Music";
                  url = "https://music.${domain}";
                  icon = "sh:navidrome";
                }
                {
                  title = "Soulseek";
                  url = "https://slsk.${domain}";
                  icon = "sh:soulseek";
                }
                {
                  title = "Home Assistant";
                  url = "https://home.${domain}";
                  icon = "sh:home-assistant";
                }
              ];
            }
          ];
        }
      ];
    }
  ];
}
