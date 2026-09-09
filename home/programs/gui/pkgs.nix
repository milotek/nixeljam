{pkgs, ...}: {
  home.packages = with pkgs; [
    vlc # Video player
    obsidian # Note taking app
    gnome-text-editor # Basic graphic text editor
    ticktick # Todo app
    pinta # Image editor
    onlyoffice-desktopeditors # Office suite
    blanket # Listen to different sounds
    signal-desktop # Messaging app
    thunar # File explorer
  ];
}
