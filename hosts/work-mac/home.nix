{
  config,
  inputs,
  ...
}: {
  imports = [
    # ── Darwin-safe modules reused from the repo (shared with your Linux hosts) ──
    ../../home/programs/tui/git # git config + aliases (uses config.var.git)
    ../../home/programs/tui/nix-utils # nix-index + comma (`, <cmd>`)
    ../../home/programs/group/dev.nix # go, node, python, uv, claude-code, jq, ...
    inputs.nvf-config.homeManagerModules.default # your neovim (nvf)

    # ── Host-local modules (faithful to THIS Mac) ──
    ./shell.nix # zsh + oh-my-zsh + powerlevel10k + your aliases/functions
    ./packages.nix # CLI toolkit (brew leaves + pc-parity extras)
    ./ghostty.nix # ghostty config (hot-reload symlink)
    ./variables.nix
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/Users/${config.var.username}";
    # Existing machine; keep 24.05 to match the rest of your hosts.
    stateVersion = "24.05";
  };

  #############################################################################
  # gMac pitfalls — home-manager side (from the internal nix guide)
  #############################################################################
  # gcert over ssh needs ForwardAgent; also route `ssh foo.c` -> foo.c.googlers.com.
  programs.ssh = {
    enable = true;
    matchBlocks."*.c" = {
      hostname = "%h.googlers.com";
      forwardAgent = true;
    };
  };

  # Android `repo` tooling expects an http cookiefile in the git config.
  programs.git.settings.http.cookiefile = "${config.home.homeDirectory}/.gitcookies";

  programs.home-manager.enable = true;
}
