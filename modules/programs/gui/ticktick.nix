# TickTick: todo app
{
  flake.modules.nixos.ticktick.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.ticktick];

        home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
          directories = [
            ".config/ticktick"
          ];
        };
      }
    )
  ];
}
