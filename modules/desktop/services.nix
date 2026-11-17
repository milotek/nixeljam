{aspects, ...}: {
  flake.modules.nixos.desktop = {pkgs, ...}: {
    imports = [
      aspects.home-manager
      aspects.niri
      aspects.noctalia
    ];

    services = {
      libinput.enable = true;
      xserver.enable = true;
      gnome.gnome-keyring.enable = true;
      psd = {
        enable = true;
        resyncTimer = "10m";
      };
      dbus = {
        implementation = "broker";
        packages = with pkgs; [
          gcr
          gnome-settings-daemon
        ];
      };
      gvfs.enable = true;
    };

    programs.dconf.enable = true;

    xdg.portal = {
      xdgOpenUsePortal = false;
      config.common.default = ["gtk"];

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
