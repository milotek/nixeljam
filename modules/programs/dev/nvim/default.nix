# Neovim, configured with nvf
# Also exposed standalone: nix run .#nvim
{inputs, ...}: let
  modules = [
    ./_options.nix
    ./_languages.nix
    ./_picker.nix
    ./_snacks.nix
    ./_keymaps.nix
    ./_utils.nix
    ./_mini.nix
  ];
in {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.nvim = (inputs.nvf.lib.neovimConfiguration {inherit pkgs modules;}).neovim;
    apps.nvim = {
      type = "app";
      program = "${self'.packages.nvim}/bin/nvim";
    };
  };

  flake.modules.nixos.nvim.home-manager.sharedModules = [
    inputs.nvf.homeManagerModules.default
    (
      {
        config,
        lib,
        ...
      }: {
        home.sessionVariables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };

        programs.nvf = {
          enable = true;
          settings = {
            vim.luaConfigRC = {
              hl-overrides = let
                c = config.theme.colors;
              in ''
                local function apply_hl()
                  vim.api.nvim_set_hl(0, "MiniStarterHeader",   { fg = "#${c.base0D}", bold = true })
                  vim.api.nvim_set_hl(0, "SnacksPickerBorder",  { fg = "#${c.base0D}" })
                  vim.api.nvim_set_hl(0, "SnacksPickerTitle",   { fg = "#${c.base0D}", bold = true })
                end
                apply_hl()
                vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = apply_hl })
              '';
            };
            imports = modules;
          };
        };
      }
    )
  ];
}
