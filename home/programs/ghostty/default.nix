{
  inputs,
  pkgs,
  config,
  ...
}: let
  dotfiles = inputs.dotfiles;
  shaders = "${dotfiles}/private_dot_config/ghostty/shaders";
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
      window-padding-y = 10;
      confirm-close-surface = false;
      clipboard-read = "allow";
      clipboard-write = "allow";
      copy-on-select = "clipboard";
      app-notifications = false;

      font-thickening = true;

      cursor-style = "bar";
      cursor-style-blink = true;
      shell-integration-features = "no-cursor";

      custom-shader = ["${shaders}/cursor_warp.glsl" "${shaders}/ripple_rectangle_cursor.glsl"];
      custom-shader-animation = "always";

      keybind = [
        "shift+ctrl+tab=new_tab"
      ];
    };
  };

  home.file.".config/ilovetui/config.yaml".text = ''
    colors:
      base00: "#${c.base00}" # Background
      base01: "#${c.base01}" # Lighter Background / Status Bars
      base02: "#${c.base02}" # Selection Background
      base03: "#${c.base03}" # Comments / Invisibles
      base04: "#${c.base04}" # Dark Foreground / Status Bars
      base05: "#${c.base05}" # Default Foreground
      base06: "#${c.base06}" # Light Foreground
      base07: "#${c.base07}" # Light Background
      base08: "#${c.base08}" # Variables / Errors / Diff Deleted
      base09: "#${c.base09}" # Integers / Constants / Booleans
      base0a: "#${c.base0A}" # Classes / Warnings / Search Background
      base0b: "#${c.base0B}" # Strings / Success / Diff Inserted
      base0c: "#${c.base0C}" # Support / Regex / Escape Characters
      base0d: "#${c.base0D}" # Functions / Methods / Headings / Accent
      base0e: "#${c.base0E}" # Keywords / Storage / Diff Changed
      base0f: "#${c.base0F}" # Embedded / Misc
  '';
}
