# Discord: chat app
{aspects, ...}: {
  flake.modules.nixos.discord.imports = [aspects.home-manager];
  flake.modules.nixos.discord.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.discord];

        home.persistence."/persist" = {
          directories = [
            ".config/discord"
          ];
        };
      }
    )
  ];
}
