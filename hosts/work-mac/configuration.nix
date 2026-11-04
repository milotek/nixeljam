{
  config,
  pkgs,
  inputs,
  pkgs-unstable,
  ...
}: {
  imports = [./variables.nix];

  networking.hostName = config.var.hostname;
  networking.computerName = config.var.hostname;
  time.timeZone = config.var.timeZone;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.primaryUser = config.var.username;
  users.users.${config.var.username} = {
    name = config.var.username;
    home = "/Users/${config.var.username}";
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    trusted-users = ["@admin" config.var.username];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  nix.gc = {
    automatic = config.var.autoGarbageCollector;
    interval.Day = 7;
    options = "--delete-older-than 7d";
  };

  # nix-darwin's /etc/zshrc and /etc/bashrc collide with Google's corp shell config.
  programs.zsh.enable = false;
  programs.bash.enable = false;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # Not "zap": that would uninstall unlisted corp-managed brews.
      cleanup = "none";
    };
    taps = [];
    brews = [];
    casks = [
      "blackhole-2ch"
      "font-monaspace"
      "ukelele"
      "zulu@8"
    ];
  };

  system.defaults = {
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv";
    };
    dock = {
      autohide = true;
      show-recents = false;
      tilesize = 48;
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    monaspace
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {inherit inputs pkgs-unstable;};
    users.${config.var.username} = import ./home.nix;
  };

  # Only bump stateVersion when nix-darwin release notes say to.
  system.stateVersion = 6;
}
