{
  # https://github.com/anotherhadi/nixy
  description = ''
    Nixy simplifies and unifies the Hyprland ecosystem with a modular, easily customizable setup.
    It provides a structured way to manage your system configuration and dotfiles with minimal effort.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    stylix.url = "github:danth/stylix";
    sops-nix.url = "github:Mic92/sops-nix";
    nvf.url = "github:notashelf/nvf";
    notashelf-tuigreet.url = "github:NotAShelf/tuigreet";
    helium-browser.url = "github:oxcl/nix-flake-helium-browser";
    nur-anotherhadi.url = "github:anotherhadi/nur-packages";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Managed separately via chezmoi — sourced here for nix-managed programs that
    # need access to dotfiles (e.g. wallpapers, config snippets).
    dotfiles = {
      url = "github:milotek/dotfiles";
      flake = false;
    };

    # Server
    nixarr.url = "github:rasmus-kirk/nixarr";
    default-creds.url = "github:anotherhadi/default-creds";
    blog.url = "github:anotherhadi/blog";
    awesome-wallpapers.url = "github:anotherhadi/awesome-wallpapers";
    iknowyou.url = "github:anotherhadi/iknowyou";

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-stable,
    ...
  }: let
    linuxSystem = "x86_64-linux";
    darwinSystem = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${linuxSystem};
    # Args passed to Linux NixOS / standalone-HM host flakes.
    args = {
      inherit inputs nixpkgs;
      system = linuxSystem;
      inherit pkgs;
      pkgs-stable = nixpkgs-stable.legacyPackages.${linuxSystem};
      pkgs-nur-hadi = inputs.nur-anotherhadi.packages.${linuxSystem};
    };
    # Args passed to Darwin (nix-darwin / standalone-HM on macOS) host flakes.
    darwinArgs = {
      inherit inputs nixpkgs;
      system = darwinSystem;
      pkgs = nixpkgs.legacyPackages.${darwinSystem};
    };
    merge = nixpkgs.lib.foldl nixpkgs.lib.recursiveUpdate {};
  in
    merge [
      (import ./home/programs/nvf/flake.nix args)
      (import ./home/programs/group/flake.nix args)
      (import ./home/programs/nixy/flake.nix args)
      {
        formatter.${linuxSystem} = pkgs.alejandra;
        formatter.${darwinSystem} = nixpkgs.legacyPackages.${darwinSystem}.alejandra;

        # NixOS hosts — deploy with: nixos-rebuild switch --flake .#<name>
        nixosConfigurations = {
          pc = import ./hosts/pc/flake.nix args; # milotek-pc-linux
          minipc = import ./hosts/minipc/flake.nix args; # milotek-minipc
          vps = import ./hosts/vps/flake.nix args; # milotek-vps
          server = import ./hosts/server/flake.nix args;
        };

        # nix-darwin hosts — deploy with: darwin-rebuild switch --flake .#<name>
        darwinConfigurations = {
          macbook = import ./hosts/macbook/flake.nix darwinArgs; # milotek-macbook
        };

        # Standalone Home Manager — deploy with: home-manager switch --flake .#<key>
        homeConfigurations = {
          "milotek@milotek-pc-windows" = import ./hosts/wsl/flake.nix args;
          "milotek@milotek-mac" = import ./hosts/work/flake.nix darwinArgs;
        };
      }
    ];
}
