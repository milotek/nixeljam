{
  flake.modules.nixos.theme = {
    lib,
    pkgs,
    config,
    ...
  }: {
    options.theme = lib.mkOption {
      type = lib.types.attrs;
      default = {
        rounding = 20;
        gaps-in = 8;
        gaps-out = 8 * 2;
        border-size = 2;

        # See https://tinted-theming.github.io/tinted-gallery/ for more schemes
        colors = {
          base00 = "0A0A0C"; # Default Background
          base01 = "110F12"; # Lighter Background (Used for status bars, line number and folding marks)
          base02 = "2D2A36"; # Selection Background
          base03 = "514D63"; # Comments, Invisibles, Line Highlighting
          base04 = "8E8AA0"; # Dark Foreground (Used for status bars)
          base05 = "C2BED6"; # Default Foreground, Caret, Delimiters, Operators
          base06 = "D8D5EA"; # Light Foreground (Not often used)
          base07 = "EAE7F7"; # Light Background (Not often used)
          base08 = "E07080"; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
          base09 = "D49070"; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
          base0A = "C4B060"; # Classes, Markup Bold, Search Text Background
          base0B = "80B880"; # Strings, Inherited Class, Markup Code, Diff Inserted
          base0C = "70B8C0"; # Support, Regular Expressions, Escape Characters, Markup Quotes
          base0D = "9E97F8"; # Functions, Methods, Attribute IDs, Headings, Accent color
          base0E = "C090E8"; # Keywords, Storage, Selector, Markup Italic, Diff Changed
          base0F = "D080A0"; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
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
          emoji = {
            package = pkgs.noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };
          size = 13;
        };

        icons = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };

        polarity = "dark";
      };
      description = "Theme configuration options";
    };

    config = let
      inherit (config.theme) cursor fonts icons;
    in {
      fonts = {
        packages = [fonts.monospace.package fonts.sansSerif.package fonts.emoji.package];
        fontconfig.defaultFonts = {
          monospace = [fonts.monospace.name];
          sansSerif = [fonts.sansSerif.name];
          serif = [fonts.sansSerif.name];
          emoji = [fonts.emoji.name];
        };
      };

      qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
      };

      home-manager.sharedModules = [
        {
          home.pointerCursor = {
            inherit (cursor) name package size;
            gtk.enable = true;
            x11.enable = true;
          };

          gtk = {
            enable = true;
            theme = {
              name = "adw-gtk3-dark";
              package = pkgs.adw-gtk3;
            };
            iconTheme = icons;
            font = {
              inherit (fonts.sansSerif) name;
              inherit (fonts) size;
            };
            # noctalia writes gtk.css when it applies a color scheme
            gtk4.theme = null;
          };

          dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-${config.theme.polarity}";
        }
      ];
    };
  };
}
