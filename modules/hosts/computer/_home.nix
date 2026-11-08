{
  config,
  lib,
  ...
}: {
  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
      directories = [
        ".config/nixos" # this repo itself (njam manages it here)
        ".local/share"
        ".local/state"
        ".cache"
        ".steam"
        "Notes"
        "Music"
        "Projects"
        "Documents"
        "Downloads"
        "Pictures"
        "Videos"
      ];

      files = [
        ".ssh/known_hosts"
        ".config/sops/age/keys.txt"
      ];
    };

    # Don't touch this
    stateVersion = "26.05";
  };

  programs = {
    home-manager.enable = true;
    njam = {
      enable = true;
      configDirectory = config.var.configDirectory;
    };
  };
}
