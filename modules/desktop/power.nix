{
  flake.modules.nixos.desktop = {
    environment.persistence."/persist".directories = [
      "/var/lib/upower" # battery calibration state
      "/var/lib/systemd/backlight" # remembers screen brightness
    ];

    services = {
      power-profiles-daemon.enable = true;
      upower = {
        enable = true;
        percentageLow = 10;
        percentageCritical = 5;
        percentageAction = 3;
      };
    };
  };
}
