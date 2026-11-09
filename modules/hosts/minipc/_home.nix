{
  config,
  inputs,
  pkgs,
  ...
}: {
  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;
    packages = [
      inputs.hermes-agent.packages.x86_64-linux.default
      pkgs.thunar
    ];

    # Don't touch this - existing install predates v6's 26.05 default.
    stateVersion = "24.05";
  };

  programs = {
    home-manager.enable = true;
    njam = {
      enable = true;
      configDirectory = config.var.configDirectory;
    };
  };
}
