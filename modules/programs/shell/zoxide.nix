# Zoxide is a cd replacement
{aspects, ...}: {
  flake.modules.nixos.shell.imports = [aspects.home-manager];
  flake.modules.nixos.shell.home-manager.sharedModules = [
    {
      programs.zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    }
  ];
}
