# Home Assistant — self-hosted smart home hub.
# Runs locally on the minipc, bound to localhost; reached from the outside via
# the reverse tunnel + Caddy (home.<domain>). Since it sits behind that proxy it
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
        server_host = "127.0.0.1";
        server_port = 8123;
        use_x_forwarded_for = true;
        trusted_proxies = ["127.0.0.1" "::1"];
      };
    };
  };
}
