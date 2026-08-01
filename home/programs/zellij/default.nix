{ lib, ... }:
{
  programs.zellij = {
    enable = true;
    # Don't auto-start in every local shell — we only want it over SSH (see below).
    enableZshIntegration = false;

    settings = {
      # Compact bar keeps the on-screen keybind hints but wastes less space —
      # nicer on a phone-sized viewport.
      default_layout = "compact";
      pane_frames = false;

      # Copy to the Wayland clipboard so yanks in a pane land on the desktop.
      copy_command = "wl-copy";

      # Keep sessions (and their scrollback/layout) on disk so a dropped phone
      # connection can reattach to exactly where it left off.
      session_serialization = true;
      serialize_pane_viewport = true;
      # Colors are left to stylix's zellij target, matching the rest of the setup.
    };
  };

  # Auto-attach a persistent "main" session, but only when coming in over SSH
  # and not already inside zellij. Reconnecting from the phone drops straight
  # back into the running session; local desktop terminals are untouched.
  programs.zsh.initContent = lib.mkAfter ''
    if [[ -n "$SSH_CONNECTION" && -z "$ZELLIJ" ]]; then
      zellij attach --create main
    fi
  '';
}
