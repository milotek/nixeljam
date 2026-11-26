{inputs, ...}: {
  flake.modules.nixos.theme = {
    lib,
    pkgs,
    config,
    ...
  }: {
    imports = [inputs.stylix.nixosModules.stylix];

    options.theme = let
      option = type: default:
        lib.mkOption {
          inherit type default;
        };
    in {
      rounding = option lib.types.int 20;
      bar-height = option lib.types.int 36;
      gaps-in = option lib.types.int 8;
      gaps-out = option lib.types.int (8 * 2);
      active-opacity = option lib.types.float 0.96;
      inactive-opacity = option lib.types.float 0.92;
      blur = option lib.types.bool false;
      border-size = option lib.types.int 2;
      animation-speed = option (lib.types.enum ["very-fast" "fast" "medium" "slow"]) "very-fast";
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
          package = pkgs.maple-mono.NF;
          name = "Maple Mono NF";
        };
        sansSerif = {
          package = pkgs.rubik;
          name = "Rubik";
        };
        serif = config.stylix.fonts.sansSerif;
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 13;
          desktop = 13;
          popups = 13;
          terminal = 13;
        };
      };

      polarity = "dark";
      image = ./wallpaper.jpg;
    };
  };
}
