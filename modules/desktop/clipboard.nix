# Clipboard history: cliphist stores every entry, noctalia's launcher browses it
{
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.wl-clipboard pkgs.cliphist];

        systemd.user.services.cliphist-wipe = {
          Unit.Description = "Wipe cliphist history on login and logout";
          Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.cliphist}/bin/cliphist wipe";
            ExecStop = "${pkgs.cliphist}/bin/cliphist wipe";
          };
          Install.WantedBy = ["default.target"];
        };

        xdg.desktopEntries.clipboard-wipe = {
          name = "Clear Clipboard History";
          exec = "${pkgs.cliphist}/bin/cliphist wipe";
          icon = "edit-clear-all-symbolic";
          comment = "Delete all clipboard history entries";
          categories = ["Utility"];
          terminal = false;
          settings.Keywords = "clipboard;history;clear;wipe;delete;cliphist;";
        };
      }
    )
  ];
}
