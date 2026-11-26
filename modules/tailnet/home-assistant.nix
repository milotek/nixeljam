{config, ...}: let
  inherit (config.flake.lib) tailnet;
in {
  flake.modules.nixos.home-assistant = {config, ...}: {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        "default_config"
        "met"
        "esphome"
        "tuya"
        "sonos"
      ];
      config = {
        default_config = {};
        automation = "!include automations.yaml";
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          time_zone = config.time.timeZone;
        };
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [tailnet.hosts.vps "127.0.0.1" "::1"];
        };
      };
    };
  };
}
