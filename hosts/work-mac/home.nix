{
  config,
  inputs,
  ...
}: {
  imports = [
    ../../home/programs/tui/git
    ../../home/programs/tui/nix-utils
    ../../home/programs/tui/ai
    ../../home/programs/group/dev.nix
    inputs.nvf-config.homeManagerModules.default

    ./shell.nix
    ./packages.nix
    ./ghostty.nix
    ./variables.nix
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/Users/${config.var.username}";
    # Existing machine; keep 24.05 to match the rest of your hosts.
    stateVersion = "24.05";
  };

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
