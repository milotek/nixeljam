# Zoxide is a cd replacement
{
  flake.modules.nixos.shell.home-manager.sharedModules = [
    {
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    }
  ];
}
