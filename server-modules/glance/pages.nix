{config, ...}: let
  domain = config.var.domain;
  powerApi = "http://100.85.180.11:5000/mc/server";

  # stylix's glance target maps positive/negative onto base01/base04, which are
  # both dark neutrals - fine for its own up/down dots, useless for telling a
  # green Start button from a red Stop one. These come straight from base16.
  colors = config.lib.stylix.colors;
  positive = "#${colors.base0B}";
  negative = "#${colors.base08}";
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
                  title = "AdGuard";
                  url = "http://localhost:3000";
                  icon = "si:adguard";
                }
                {
                  title = "Files";
                  url = "https://files.${domain}";
                  icon = "si:files";
                }
                {
                  title = "Music";
                  url = "https://music.${domain}";
                  icon = "si:navidrome";
                }
                {
                  title = "Soulseek";
                  url = "https://slsk.${domain}";
                  icon = "si:soundcharts";
                }
                {
                  title = "Home Assistant";
                  url = "https://home.${domain}";
                  icon = "si:homeassistant";
                }
              ];
            }

            {
              type = "custom-api";
              title = "Minecraft";
              # mcstatus.io pings the server the same way a player's client
              # would, so this reports reachability rather than just whether
              # the unit happens to be running.
              url = "https://api.mcstatus.io/v2/status/java/mc.${domain}";
              cache = "30s";
              template = ''
                <div style="display: flex; align-items: center; gap: 12px;">
                  <div style="flex-grow: 1; min-width: 0;">
                    <a class="size-h4 block text-truncate color-highlight">
                      mc.${domain}
                      {{ if .JSON.Bool "online" }}
                        <span style="width: 8px; height: 8px; border-radius: 50%; background-color: ${positive}; display: inline-block; vertical-align: middle;"></span>
                      {{ else }}
                        <span style="width: 8px; height: 8px; border-radius: 50%; background-color: ${negative}; display: inline-block; vertical-align: middle;"></span>
                      {{ end }}
                    </a>
                    <ul class="list-horizontal-text">
                      {{ if .JSON.Bool "online" }}
                        <li>{{ .JSON.String "version.name_clean" }}</li>
                        <li>{{ .JSON.Int "players.online" | formatNumber }}/{{ .JSON.Int "players.max" | formatNumber }} players</li>
                      {{ else }}
                        <li>Offline</li>
                      {{ end }}
                    </ul>
                  </div>

                  <div>
                    {{ if .JSON.Bool "online" }}
                      <button onclick="mcPower('stop', this)" class="mc-power mc-stop">Stop</button>
                    {{ else }}
                      <button onclick="mcPower('start', this)" class="mc-power mc-start">Start</button>
                    {{ end }}
                  </div>
                </div>

                <script>
                  function mcPower(action, button) {
                    button.disabled = true;
                    button.textContent = action === 'start' ? 'Starting...' : 'Stopping...';
                    fetch('${powerApi}/' + action, {
                      method: 'POST',
                      headers: { 'Authorization': 'Bearer ''${MC_API_KEY}' }
                    })
                      // The server takes a while to finish binding its port, so
                      // reloading immediately would just show the old state.
                      .then(() => setTimeout(() => location.reload(), 15000))
                      .catch(() => { button.disabled = false; button.textContent = 'Failed'; });
                  }
                </script>

                <style>
                  .mc-power { padding: 8px 16px; color: white; border: none; border-radius: 4px; transition: opacity 0.3s ease; }
                  .mc-power:hover { opacity: 0.7; }
                  .mc-power:disabled { opacity: 0.5; }
                  .mc-start { background-color: ${positive}; }
                  .mc-stop { background-color: ${negative}; }
                </style>
              '';
            }
          ];
        }
      ];
    }
  ];
}
