{
  flake.modules.nixos.navi.home-manager.sharedModules = [
    {
      programs.navi = {
        enable = true;
      };
    }
  ];
}
