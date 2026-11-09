# Eza is a ls replacement
{
  flake.modules.nixos.shell.home-manager.sharedModules = [
    {
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
