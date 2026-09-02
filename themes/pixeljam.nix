{
  lib,
  pkgs,
  config,
  ...
}: {
  options.theme = lib.mkOption {
    type = lib.types.attrs;
    default = {
      rounding = 20;
      bar-height = 36; # v6 schema: replaced bar-rounding/bar-thickness (waybar/tofi read bar-height)
      gaps-in = 8;
      gaps-out = 8 * 2;
      active-opacity = 0.96;
      inactive-opacity = 0.92;
      blur = true;
      border-size = 2;
      animation-speed = "medium"; # "very-fast" | "fast" | "medium" | "slow"
    };
    description = "Theme configuration options";
  };

  config.stylix = {
    enable = true;

    # See https://tinted-theming.github.io/tinted-gallery/ for more schemes
    base16Scheme = {
      base00 = "1e1e2e"; # Default Background
      base01 = "181825"; # Lighter Background (Used for status bars, line number and folding marks)
      base02 = "313244"; # Selection Background
      base03 = "45475a"; # Comments, Invisibles, Line Highlighting
      base04 = "585b70"; # Dark Foreground (Used for status bars)
      base05 = "cdd6f4"; # Default Foreground, Caret, Delimiters, Operators
      base06 = "f5c2e7"; # Light Foreground (Not often used)
      base07 = "b4befe"; # Light Background (Not often used)
      base08 = "f38ba8"; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
      base09 = "fab387"; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
      base0A = "f9e2af"; # Classes, Markup Bold, Search Text Background
      base0B = "a6e3a1"; # Strings, Inherited Class, Markup Code, Diff Inserted
      base0C = "94e2d5"; # Support, Regular Expressions, Escape Characters, Markup Quotes
      base0D = "ffbdbd"; # Functions, Methods, Attribute IDs, Headings, Accent color
      base0E = "cba4f7"; # Keywords, Storage, Selector, Markup Italic, Diff Changed
      base0F = "f2cdcd"; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
    };

    cursor = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      size = 20;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.meslo-lg;
        name = "MesloLGS Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.source-sans;
        name = "Source Sans 3";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      emoji = {
        package = pkgs.twitter-color-emoji;
        name = "Twitter Color Emoji";
      };
      sizes = {
        applications = 12;
        desktop = 12;
        popups = 12;
        terminal = 12;
      };
    };

    polarity = "dark";
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/anotherhadi/awesome-wallpapers/refs/heads/main/app/static/wallpapers/black-moutains-and-a-city.png";
      sha256 = "sha256-RTTA3Lf+hnPpo9hwS075kbnIouz12ul2GKO3EIgP6AU=";
    };
  };
}
