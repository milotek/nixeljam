# Home Assistant — self-hosted smart home hub.
# Runs locally on the minipc, reachable over the tailnet; Caddy on the VPS
# fronts it publicly at home.<domain>. Since it sits behind that proxy it
# needs use_x_forwarded_for + trusted_proxies or it rejects the forwarded host.
{config, ...}: {
  services.home-assistant = {
    enable = true;

    # Pulls in the sane defaults (frontend, history, energy, mobile app, etc.).
    extraComponents = [
      "default_config"
      "met" # weather
      "esphome"
      "mobile_app"
    ];

    config = {
      default_config = {};

      homeassistant = {
        name = "Home";
        unit_system = "metric";
        time_zone = config.var.timeZone;
      };

      http = {
        server_host = "0.0.0.0";
        server_port = 8123;
        use_x_forwarded_for = true;
        trusted_proxies = ["100.117.236.50" "127.0.0.1" "::1"];
      };
    };
  };
}
