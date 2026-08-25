{
  config,
  pkgs,
  ...
}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # protonup-ng installs Proton-GE builds here; Steam only picks them up if
  # this path is exported.
  environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/${config.var.username}/.steam/root/compatibilitytools.d";

  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      {
        appId = "org.vinegarhq.Sober";
        origin = "flathub";
      }
    ];
  };

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # needed for KMS/DRM screen capture on Wayland
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    moonlight-qt
    vinegar
    prismlauncher
    modrinth-app
    osu-lazer
    mangohud
    protonup-ng
  ];
}
