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
    capSysAdmin = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    moonlight-qt
    vinegar
    prismlauncher
    modrinth-app
    mangohud
    protonup-ng
  ];
}
