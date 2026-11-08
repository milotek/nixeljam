# VS Code: code editor
{
  flake.modules.nixos.vscode.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.vscode];

        home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
          directories = [
            ".config/Code"
            ".vscode"
          ];
        };
      }
    )
  ];
}
