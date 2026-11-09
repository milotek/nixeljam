{
  # Forked from https://github.com/anotherhadi/nixy
  description = ''
    nixeljam: a ready-to-use NixOS desktop built on niri and noctalia, for people new to NixOS.
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nvf.url = "github:notashelf/nvf";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      # Pinned: lib/sandbox.nix patches its launcher source
      url = "github:nixpak/nixpak/dd037bd073edc9f8ce2186c6c1975f47db245bed";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/v4.7.6";
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
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tldr-pages-src = {
      url = "github:tldr-pages/tldr";
      flake = false;
    };

    # Server
    nixarr.url = "github:nix-media-server/nixarr";

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak"; # gaming.nix flatpak (Sober)
    hermes-agent.url = "github:NousResearch/hermes-agent";
    minegrub-world-sel-theme = {
      url = "github:Lxtharia/minegrub-world-sel-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    habits = {
      url = "github:milotek/habits";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # midi playback for copyparty until it lands upstream. Deliberately NOT
    # following our nixpkgs: the fork's flake is pinned to 25.05, and the
    # python packageset it overlays does not exist in 26.05 unchanged.
    copyparty-midi.url = "github:milotek/copyparty-midi-support/midi-support";
  };

  # Dendritic layout: every file under ./modules is a flake-parts module
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
