# Sway: i3-compatible tiling Wayland compositor (wlroots based).
# Unlike the Hyprland module it uses the prebuilt nixpkgs package (in the binary
# cache), so it needs no from-source compile - a better fit for the minipc.
{pkgs, ...}: {
  # Make Sway selectable at login. tuigreet reads sessions from the system
  # profile (/run/current-system/sw/share/wayland-sessions), which programs.sway
  # does not populate, so drop the session file there. /share/wayland-sessions
  # is not in the default pathsToLink, so it must be added explicitly.
  environment.pathsToLink = ["/share/wayland-sessions"];
  environment.systemPackages = [
    (pkgs.runCommandLocal "sway-wayland-session" {} ''
      install -Dm444 ${pkgs.sway}/share/wayland-sessions/sway.desktop \
        "$out/share/wayland-sessions/sway.desktop"
    '')
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      fuzzel # application launcher
      grim # screenshots
      slurp # region select
      wl-clipboard
      brightnessctl
    ];
  };

  # File pickers / screencast portals for wlroots compositors.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
