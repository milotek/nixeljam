# Noctalia is the desktop shell: bar, launcher, notifications, lock screen, OSD and wallpaper
# Its settings are seeded once and stay writable, so themes can be switched from its settings
{inputs, ...}: {
  flake.modules.nixos.noctalia.home-manager.sharedModules = [
    inputs.noctalia.homeModules.default
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: let
        c = lib.mapAttrs (_: v: "#${v}") config.theme.colors;
        json = (pkgs.formats.json {}).generate;

        palette = {
          mPrimary = c.base0D;
          mOnPrimary = c.base00;
          mSecondary = c.base0E;
          mOnSecondary = c.base00;
          mTertiary = c.base0C;
          mOnTertiary = c.base00;
          mError = c.base08;
          mOnError = c.base00;
          mSurface = c.base00;
          mOnSurface = c.base05;
          mSurfaceVariant = c.base01;
          mOnSurfaceVariant = c.base04;
          mOutline = c.base03;
          mShadow = c.base00;
          mHover = c.base0C;
          mOnHover = c.base00;
          terminal = {
            normal = {
              black = c.base02;
              red = c.base08;
              green = c.base0B;
              yellow = c.base0A;
              blue = c.base0D;
              magenta = c.base0E;
              cyan = c.base0C;
              white = c.base05;
            };
            bright = {
              black = c.base03;
              red = c.base08;
              green = c.base0B;
              yellow = c.base0A;
              blue = c.base0D;
              magenta = c.base0E;
              cyan = c.base0C;
              white = c.base07;
            };
            foreground = c.base05;
            background = c.base00;
            selectionFg = c.base05;
            selectionBg = c.base02;
            cursorText = c.base00;
            cursor = c.base05;
          };
        };

        overrides = json "noctalia-overrides.json" {
          appLauncher = {
            terminalCommand = "${pkgs.ghostty}/bin/ghostty -e";
            enableClipboardHistory = true;
          };
          colorSchemes.predefinedScheme = "Nixy";
          templates.activeTemplates = map (id: {
            inherit id;
            enabled = true;
          }) ["gtk" "qt" "ghostty" "niri" "btop"];
          ui = {
            fontDefault = config.theme.fonts.sansSerif.name;
            fontFixed = config.theme.fonts.monospace.name;
          };
        };

        settings = pkgs.runCommand "noctalia-settings.json" {nativeBuildInputs = [pkgs.jq];} ''
          shell=${config.programs.noctalia-shell.package}/share/noctalia-shell
          version=$(grep -oP 'readonly property int settingsVersion: \K[0-9]+' $shell/Commons/Settings.qml)
          jq --argjson version "$version" --slurpfile o ${overrides} \
            '. * $o[0] | .settingsVersion = $version' $shell/Assets/settings-default.json > $out
        '';
      in {
        programs.noctalia-shell = {
          enable = true;
          package = pkgs.noctalia-shell;
          systemd.enable = true;
        };

        xdg.configFile."noctalia/colorschemes/Nixy/Nixy.json".source = json "Nixy.json" {
          dark = palette;
          light = palette;
        };

        # C copies only when the file is missing: changes made in noctalia are kept.
        # shell-state.json marks this version as set up: no first-run wizard or changelog popup
        systemd.user.tmpfiles.rules = [
          "C %h/.config/noctalia/settings.json - - - - ${settings}"
          "C %h/.cache/noctalia/shell-state.json - - - - ${json "shell-state.json" {
            changelogState.lastSeenVersion = "v${pkgs.noctalia-shell.version}";
          }}"
          "f %h/.config/niri/noctalia.kdl"
          "f %h/.config/ghostty/themes/noctalia"
        ];
      }
    )
  ];
}
