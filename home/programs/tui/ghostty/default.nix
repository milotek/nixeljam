# Ghostty is a terminal emulator
{
  pkgs,
  config,
  ...
}: let
  cursorShaders = pkgs.fetchFromGitHub {
    owner = "sahaj-b";
    repo = "ghostty-cursor-shaders";
    rev = "06d4e90fb5410e9c4d0b3131584060adddf89406";
    hash = "sha256-G/UIr1bKnxn1AcHl/4FL/jou6b7M2VeREslYVELxdmw=";
  };
  c = config.lib.stylix.colors;
in {
  home.sessionVariables = {
    TERMINAL = "ghostty";
    TERM = "ghostty";
  };

  programs.ghostty = {
    enable = true;
    installVimSyntax = true;
    enableZshIntegration = true;
    settings = {
      window-padding-x = 10;
      confirm-close-surface = false;
      window-padding-y = 10;
      gtk-single-instance = true;
      clipboard-read = "allow";
      clipboard-write = "allow";
      copy-on-select = "clipboard";
      app-notifications = false;
      custom-shader = "${cursorShaders}/cursor_warp.glsl";
      custom-shader-animation = "always";
      # The terminal is the only place Ctrl means two things at once: an application
      # shortcut everywhere else on the desktop, and a control character here. Ctrl
      # gets the application meaning and Super carries the control characters, which
      # is the separation a Mac gets from having Cmd as a spare modifier.
      keybind =
        [
          "ctrl+t=new_tab"
          "ctrl+w=close_surface"
          "ctrl+n=new_window"
          "ctrl+a=select_all"
          "ctrl+z=undo"
          "ctrl+shift+z=redo"
          "ctrl+tab=next_tab"
          "ctrl+shift+tab=previous_tab"
          "ctrl+v=paste_from_clipboard"

          # Copies with a selection up and otherwise falls through, so the interrupt
          # reflex still works here and over ssh.
          "performable:ctrl+c=copy_to_clipboard"

          # The control characters displaced above. Without these the shell loses
          # start-of-line, interrupt, suspend, delete-word and fzf's file widget.
          "super+a=text:\\x01"
          "super+c=text:\\x03"
          "super+t=text:\\x14"
          "super+v=text:\\x16"
          "super+w=text:\\x17"
          "super+z=text:\\x1a"

          # Text navigation, as the control characters and escapes the line editor
          # already binds by default: ^A, ^E, ESC-b, ESC-f, ^W and ^U.
          "ctrl+left=text:\\x01"
          "ctrl+right=text:\\x05"
          "ctrl+backspace=text:\\x15"
          "alt+left=text:\\x1bb"
          "alt+right=text:\\x1bf"
          "alt+backspace=text:\\x17"
          "ctrl+up=scroll_page_up"
          "ctrl+down=scroll_page_down"
        ]
        ++ builtins.genList (
          i: "ctrl+${toString (i + 1)}=goto_tab:${toString (i + 1)}"
        )
        9;
    };
  };
}
