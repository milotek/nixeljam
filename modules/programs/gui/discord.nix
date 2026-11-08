# Discord: chat app
{
  flake.modules.nixos.discord.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.discord];

        home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
          directories = [
            ".config/discord"
          ];
        };
      }
    )
  ];
}
