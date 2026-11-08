# Niri is a scrollable-tiling Wayland compositor.
{
  flake.modules.nixos.niri = {pkgs, ...}: {
    programs.niri.enable = true;

    # X11 apps (Steam, games...): niri starts it on demand when it's in PATH
    environment.systemPackages = [pkgs.xwayland-satellite];

    # Generic Wayland hints (Chromium/Electron and Firefox), applied on every
    # niri host regardless of the GPU.
    environment.variables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    home-manager.sharedModules = [
      (
        {
          config,
          lib,
          osConfig,
          pkgs,
          ...
        }: let
          c = config.theme.colors;
          inherit (config) theme;
          noctalia = cmd: ''spawn "${pkgs.noctalia-shell}/bin/noctalia-shell" "ipc" "call" ${lib.concatMapStringsSep " " (a: ''"${a}"'') (lib.splitString " " cmd)}'';
          playerctl = "${pkgs.playerctl}/bin/playerctl";
        in {
          xdg.configFile."niri/config.kdl".text = ''
            input {
                keyboard {
                    xkb {
                        layout "${osConfig.var.keyboardLayout}"
                    }
                    numlock
                }
                touchpad {
                    tap
                    natural-scroll
                }
                focus-follows-mouse max-scroll-amount="0%"
            }

            layout {
                gaps ${toString theme.gaps-in}
                background-color "transparent"
                center-focused-column "never"
                preset-column-widths {
                    proportion 0.33333
                    proportion 0.5
                    proportion 0.66667
                }
                default-column-width { proportion 0.5; }
                focus-ring {
                    width ${toString theme.border-size}
                    active-color "#${c.base0D}"
                    inactive-color "#${c.base03}"
                }
                border {
                    off
                }
            }

            prefer-no-csd
            screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

            hotkey-overlay {
                skip-at-startup
            }

            window-rule {
                geometry-corner-radius ${toString theme.rounding}
                clip-to-geometry true
            }

            // noctalia's wallpaper stays visible behind the overview
            layer-rule {
                match namespace="^noctalia-wallpaper"
                place-within-backdrop true
            }

            binds {
                Mod+Shift+Slash { show-hotkey-overlay; }

                // Quick launch
                Mod+Return { spawn "${pkgs.ghostty}/bin/ghostty" "+new-window"; }
                Mod+B { spawn "${pkgs.google-chrome}/bin/google-chrome-stable"; }
                Mod+Space { ${noctalia "launcher toggle"}; }
                Mod+V { ${noctalia "launcher clipboard"}; }
                Mod+N { ${noctalia "notifications toggleHistory"}; }
                Mod+X { ${noctalia "sessionMenu toggle"}; }
                Super+Alt+L { ${noctalia "lockScreen lock"}; }

                // Windows
                Mod+Q repeat=false { close-window; }
                Mod+F { fullscreen-window; }
                Mod+Shift+F { toggle-window-floating; }
                Mod+R { switch-preset-column-width; }
                Mod+C { center-column; }
                Mod+O repeat=false { toggle-overview; }

                // Focus
                Mod+H { focus-column-left; }
                Mod+J { focus-window-down; }
                Mod+K { focus-window-up; }
                Mod+L { focus-column-right; }
                Mod+Left { focus-column-left; }
                Mod+Down { focus-window-down; }
                Mod+Up { focus-window-up; }
                Mod+Right { focus-column-right; }
                Mod+Shift+H { focus-monitor-left; }
                Mod+Shift+L { focus-monitor-right; }

                // Move
                Mod+Ctrl+H { move-column-left; }
                Mod+Ctrl+J { move-window-down; }
                Mod+Ctrl+K { move-window-up; }
                Mod+Ctrl+L { move-column-right; }

                // Workspaces
                ${lib.concatMapStrings (i: let
              ws = toString i;
            in ''
              Mod+${ws} { focus-workspace ${ws}; }
                  Mod+Shift+${ws} { move-column-to-workspace ${ws}; }
            '') (lib.range 1 9)}
                Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }
                Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }

                // Screenshots
                Print { screenshot; }
                Shift+Print { screenshot-screen; }
                Alt+Print { screenshot-window; }

                // Sound
                XF86AudioRaiseVolume allow-when-locked=true { ${noctalia "volume increase"}; }
                XF86AudioLowerVolume allow-when-locked=true { ${noctalia "volume decrease"}; }
                XF86AudioMute allow-when-locked=true { ${noctalia "volume muteOutput"}; }
                XF86AudioMicMute allow-when-locked=true { ${noctalia "volume muteInput"}; }

                // Media
                XF86AudioPlay allow-when-locked=true { spawn "${playerctl}" "play-pause"; }
                XF86AudioPause allow-when-locked=true { spawn "${playerctl}" "play-pause"; }
                XF86AudioNext allow-when-locked=true { spawn "${playerctl}" "next"; }
                XF86AudioPrev allow-when-locked=true { spawn "${playerctl}" "previous"; }

                // Brightness
                XF86MonBrightnessUp allow-when-locked=true { ${noctalia "brightness increase"}; }
                XF86MonBrightnessDown allow-when-locked=true { ${noctalia "brightness decrease"}; }
            }

            include "./noctalia.kdl"
          '';
        }
      )
    ];
  };
}
