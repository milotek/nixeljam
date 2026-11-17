# Eza is a ls replacement
{aspects, ...}: {
  flake.modules.nixos.shell.imports = [aspects.home-manager];
  flake.modules.nixos.shell.home-manager.sharedModules = [
    {
      programs.zsh.initContent = ''
        compdef eza=ls
      '';
      programs.eza = {
        enable = true;
        icons = "auto";

        extraOptions = [
          "--group-directories-first"
          "--no-quotes"
          "--icons=always"
        ];
      };
    }
  ];
}
