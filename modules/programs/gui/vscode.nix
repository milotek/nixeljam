# VS Code: code editor
{aspects, ...}: {
  flake.modules.nixos.vscode.imports = [aspects.home-manager];
  flake.modules.nixos.vscode.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.unstable.vscode];

        home.persistence."/persist" = {
          directories = [
            ".config/Code"
            ".vscode"
          ];
        };
      }
    )
  ];
}
