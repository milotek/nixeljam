{
  # https://github.com/anotherhadi/nixy
  description = ''
    Nixy simplifies and unifies the Hyprland ecosystem with a modular, easily customizable setup.
    It provides a structured way to manage your system configuration and dotfiles with minimal effort.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nvf.url = "github:notashelf/nvf";
    nvf-config = {
      url = "path:./home/programs/tui/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nvf.follows = "nvf";
    };
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    minegrub-world-sel-theme = {
      url = "github:Lxtharia/minegrub-world-sel-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Server
    nixarr.url = "github:nix-media-server/nixarr";
    default-creds.url = "github:anotherhadi/default-creds";
    blog.url = "github:anotherhadi/blog";
    awesome-wallpapers.url = "github:anotherhadi/awesome-wallpapers";
    iknowyou.url = "github:anotherhadi/iknowyou";
    habits = {
      url = "github:milotek/habits";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    nixpkgs,
    nixpkgs-unstable,
    git-hooks,
    ...
  }: let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs = nixpkgs.legacyPackages.${system};
    args = {
      inherit
        inputs
        nixpkgs
        system
        pkgs-unstable
        pkgs
        ;
    };
    merge = nixpkgs.lib.foldl nixpkgs.lib.recursiveUpdate {};

    darwinSystem = "aarch64-darwin";
    darwinArgs = {
      inherit inputs nixpkgs;
      system = darwinSystem;
      pkgs = nixpkgs.legacyPackages.${darwinSystem};
      pkgs-unstable = import nixpkgs-unstable {
        system = darwinSystem;
        config.allowUnfree = true;
      };
    };

    supportedSystems = ["x86_64-linux" "aarch64-linux"];

    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems
      (system: f system (import nixpkgs {inherit system;}));
  in
    merge [
      (import ./home/programs/tui/nixy/flake.nix args)
      {
        formatter.${system} = pkgs.alejandra;
        packages.${system} = {
          nvim = inputs.nvf-config.packages.${system}.nvim;
          tidyname = import ./pkgs/tidyname/package.nix {inherit pkgs;};
        };
        apps.${system}.nvim = inputs.nvf-config.apps.${system}.nvim;
        nixosConfigurations = {
          pc = import ./hosts/pc/flake.nix args;
          minipc = import ./hosts/minipc/flake.nix args;
          vps = import ./hosts/vps/flake.nix args;
          wsl = import ./hosts/wsl/flake.nix args;
        };
        darwinConfigurations = {
          work-mac = import ./hosts/work-mac/flake.nix darwinArgs;
        };
        devShells = forAllSystems (system: pkgs: {
          default = import ./shell.nix {
            inherit pkgs;
            gitHooksLib = git-hooks.lib.${system};
          };
        });
      }
    ];
}
