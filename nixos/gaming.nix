{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  services.flatpak.enable = true;

  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  services.flatpak.packages = [
    { appId = "org.vinegarhq.Sober"; origin = "flathub"; }
  ];

  environment.systemPackages = with pkgs; [
    vinegar
    prismlauncher # Minecraft instance/mod launcher
    modrinth-app # Modrinth's Minecraft launcher
  ];
}
