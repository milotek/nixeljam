{
  flake.modules.nixos.zellij.home-manager.sharedModules = [
    (
      {
        lib,
        pkgs,
        config,
        ...
      }: let
        # A yank should land in the clipboard of whatever is physically in front of
        # you. Headless hosts have neither a compositor nor pbcopy, so leave this
        # unset there and let zellij fall back to OSC 52, which reaches the terminal
        # you SSH'd in from rather than a clipboard nobody can see.
        copyCommand =
          if pkgs.stdenv.isDarwin
          then "pbcopy"
          else if config.wayland.windowManager.hyprland.enable
          then "wl-copy"
          else null;
      in {
        programs.zellij = {
          enable = true;
          # The generated auto-start snippet runs a bare `zellij attach -c`, which
          # picks whichever session was used last. We want the choice to depend on
          # local vs SSH instead, so the attach is done by hand in initContent below.
          enableZshIntegration = false;

          settings =
            {
              default_layout = "compact";
              pane_frames = false;

              # So a dropped phone connection reattaches to exactly what was on screen.
              serialize_pane_viewport = true;

              mirror_session = false;
            }
            // lib.optionalAttrs (copyCommand != null) {copy_command = copyCommand;}
            # Sessions started in a terminal are not reachable from the web client
            # unless they are allowed to be shared. Only hosts running the server
            # (server-modules/zellij-web.nix) set this.
            // lib.optionalAttrs (config.var.zellijWeb or false) {web_sharing = "on";};
        };

        # A tiling WM retiles on every new terminal, so no two windows are the same
        # size. A shared session would clamp every window to the smallest one, so each
        # local window gets a session of its own. These are throwaway, hence
        # serialization off - otherwise every closed window leaves a resurrectable
        # corpse in `zellij ls`.
        #
        # SSH is the opposite case: one shared "main" per host that survives a dropped
        # phone or Mac connection and reattaches where it left off.
        programs.zsh.initContent = lib.mkAfter ''
          if [[ -z "$ZELLIJ" ]]; then
            if [[ -n "$SSH_CONNECTION" ]]; then
              zellij attach --create main
            else
              zellij attach --create "w$$" options --session-serialization false
            fi
          fi
        '';
      }
    )
  ];
}
