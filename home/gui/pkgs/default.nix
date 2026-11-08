{
  pkgs,
  config,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    vlc # Video player
    obsidian # Note taking app
    onlyoffice-desktopeditors # Office suite
    signal-desktop # Messaging app

    gnome-text-editor
  ];

  home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
    directories = [
      ".config/Signal"
      ".config/obsidian"
    ];
  };
}
