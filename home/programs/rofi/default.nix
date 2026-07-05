# Rofi application launcher / switcher (Wayland build).
# Theming (colors/font) is handled automatically by stylix's rofi target.
{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      drun-display-format = "{name}";
      display-drun = "Apps";
      display-run = "Run";
      display-window = "Windows";
    };
  };
}
