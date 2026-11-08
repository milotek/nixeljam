# Neovim

The Neovim configuration is built with [nvf](https://github.com/notashelf/nvf) and exposed as a standalone flake output.
It can be used in three ways: run it directly, import it into another flake's NixOS config, or use it as part of this config.

## Run directly

No installation needed:

```sh
nix run github:milotek/nixeljam#nvim
```

## Use in another flake

Add this repo as an input:

```nix
inputs.nixeljam.url = "github:milotek/nixeljam";
```

Then import the `nvim` aspect in your NixOS configuration:

```nix
{ inputs, ... }: {
  imports = [ inputs.nixeljam.nixosModules.nvim ];
}
```

## What's included

| File (`modules/programs/dev/nvim/`) | Description                                                            |
| --------------- | ---------------------------------------------------------------------- |
| `_options.nix`   | Core settings: theme (catppuccin mocha), clipboard, indentation, folds |
| `_languages.nix` | LSP, treesitter, formatters, diagnostics, and per-language config      |
| `_keymaps.nix`   | All key mappings (leader: `space`)                                     |
| `_picker.nix`    | Snacks picker + oil.nvim                                               |
| `_snacks.nix`    | Snacks extras: image preview, zen mode, git signs, statuscolumn        |
| `_utils.nix`     | Bufferline, lualine, copilot, lazygit, toggleterm, autocomplete        |
| `_mini.nix`      | Mini.nvim suite: ai, clue, comment, diff, git, icons, indentscope, jump2d, pairs, starter, statusline, surround |
