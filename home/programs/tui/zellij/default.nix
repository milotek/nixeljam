{ lib, ... }:
{
  programs.zellij = {
    enable = true;
    # The generated auto-start snippet runs a bare `zellij attach -c`, which
    # picks whichever session was used last. We want a fixed session instead,
    # so the attach is done by hand in initContent below.
    enableZshIntegration = false;

    settings = {
      # Compact bar keeps the on-screen keybind hints but wastes less space -
      # nicer on a phone-sized viewport.
      default_layout = "compact";
      pane_frames = false;

      # Copy to the Wayland clipboard so yanks in a pane land on the desktop.
      copy_command = "wl-copy";

      # Non-default: keep pane viewports on disk too, so a dropped phone
      # connection reattaches to exactly what was on screen.
      serialize_pane_viewport = true;

      # Each client keeps its own cursor and focus, so the phone can sit on a
      # different pane without dragging the desktop along. Mirroring would also
      # force both screens down to the smaller one's width.
      mirror_session = false;
      # Colors are left to stylix's zellij target, matching the rest of the setup.
    };
  };

  # One shared session called "main", attached by every interactive shell,
  # local and over SSH alike. Reconnecting from any device lands in the same
  # panes rather than starting somewhere new.
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -z "$ZELLIJ" ]]; then
      zellij attach --create main
    fi
  '';
}
