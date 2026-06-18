{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [./variables.nix];

  networking.hostName = config.var.hostname;
  time.timeZone = config.var.timeZone;

  services.nix-daemon.enable = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  nix.gc = {
    automatic = config.var.autoGarbageCollector;
    interval.Day = 7;
    options = "--delete-older-than 7d";
  };

  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {inherit inputs;};
    users."${config.var.username}" = import ./home.nix;
  };

  system.stateVersion = 5;
}
