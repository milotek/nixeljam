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
        # Compact bar keeps the on-screen keybind hints but wastes less space -
        # nicer on a phone-sized viewport.
        default_layout = "compact";
        pane_frames = false;

        # Non-default: keep pane viewports on disk too, so a dropped phone
        # connection reattaches to exactly what was on screen.
        serialize_pane_viewport = true;

        # Each client gets its own cursor and its own focused tab. Note this
        # does not give clients their own size: a session has one viewport,
        # clamped to the smallest attached client, mirrored or not. That is why
        # local windows get a session each below.
        mirror_session = false;
        # Colors are left to stylix's zellij target, matching the rest of the setup.
      }
      // lib.optionalAttrs (copyCommand != null) {copy_command = copyCommand;}
      # Sessions started in a terminal are not reachable from the web client
      # unless they are allowed to be shared. Only hosts running the server
      # (server-modules/zellij-web.nix) set this.
      // lib.optionalAttrs (config.var.zellijWeb or false) {web_sharing = "on";};
  };

  # A tiling WM retiles on every new terminal, so no two windows are the same
  # size. Sharing one session across them would clamp every window to the
  # smallest one, so each local window gets a session of its own. These are
  # throwaway, hence serialization off - otherwise every closed window leaves a
  # resurrectable corpse in `zellij ls`.
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
