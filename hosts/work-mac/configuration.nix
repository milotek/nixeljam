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

  # Required by recent nix-darwin for user-scoped options.
  system.primaryUser = config.var.username;
  users.users.${config.var.username} = {
    name = config.var.username;
    home = "/Users/${config.var.username}";
  };

  # NOTE (gMac): Nix builds binaries in a sandbox, so they won't appear on
  # Santa's allowlist. Switch to "minimal protection" on go/upvote-hosts BEFORE
  # rebuilding, or the daemon/build steps may be blocked. Do NOT request the
  # 1-year exception (needs manual security approval).
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

  # nix-darwin manages /etc/zshrc & /etc/bashrc, which collide with Google's
  # system-wide shell config. Disable so we don't fight corp management.
  # (home-manager still manages the user-level ~/.zshrc - that is independent.)
  programs.zsh.enable = false;
  programs.bash.enable = false;

  # Homebrew itself must already be installed
  # (it is: /opt/homebrew). nix-darwin only manages the package list.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      # SAFE DEFAULT for a corp machine: never uninstall packages that aren't
      # listed here. Once you've confirmed every brew you care about is captured
      # below, flip this to "zap" for a fully-declarative Homebrew.
      cleanup = "none";
    };
    taps = [];
    # Terminal CLIs are intentionally managed via home-manager instead (see
    # packages.nix) so they can be shared with your Linux hosts.
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
      FXPreferredViewStyle = "Nlsv"; # list view
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

  # Only bump when release notes instruct you to.
  system.stateVersion = 6;
}
