{
  lib,
  pkgs,
  config,
  ...
}: let
  copyCommand =
    if pkgs.stdenv.isDarwin
    then "pbcopy"
    else if config.wayland.windowManager.hyprland.enable
    then "wl-copy"
    else null;
in {
  programs.zellij = {
    enable = true;
    # Attach is done by hand in initContent below.
    enableZshIntegration = false;

    settings =
      {
        default_layout = "compact";
        pane_frames = false;
        serialize_pane_viewport = true;
        mirror_session = false;
      }
      // lib.optionalAttrs (copyCommand != null) {copy_command = copyCommand;}
      // lib.optionalAttrs (config.var.zellijWeb or false) {web_sharing = "on";};
  };

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
