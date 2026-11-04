{config, ...}: let
  vps = "100.117.236.50"; # the VPS's tailnet address; caddy proxies home.<domain> from there
in {
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "tuya"
    ];
    config = {
      default_config = {};
      homeassistant = {
        name = "Home";
        unit_system = "metric";
        time_zone = config.var.timeZone;
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [vps "127.0.0.1" "::1"];
      };
    };
  };
}
