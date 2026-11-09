{config, ...}: {
  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
