# Extending nixeljam

## Install an app quickly

Find it on [search.nixos.org](https://search.nixos.org/packages), then add it to
your host's `_home.nix` (just for your user):

```nix
home.packages = with pkgs; [
  blender
  prismlauncher
];
```

or to `_configuration.nix` (for every user):

```nix
environment.systemPackages = with pkgs; [
  blender
];
```

Then run `njam rebuild`. Add `pkgs` to the arguments at the top of the file if it
isn't there yet.

## Write an aspect

An aspect is one file that defines one feature. Every `.nix` file under
`modules/` is loaded automatically, except files and folders starting with `_`.

Here is a whole app, `modules/programs/gui/blender.nix`:

```nix
# Blender: 3D creation suite
{
  flake.modules.nixos.blender.home-manager.sharedModules = [
    (
      {
        config,
        lib,
        pkgs,
        ...
      }: {
        home.packages = [pkgs.blender];

        home.persistence."/persist" = lib.mkIf (config.var.impermanenceEnabled or false) {
          directories = [".config/blender"];
        };
      }
    )
  ];
}
```

- `flake.modules.nixos.<name>` is the system side, anything you'd write in
  `configuration.nix` (services, system packages, hardware...).
- `home-manager.sharedModules` is the user side, anything you'd write in a
  home-manager config (`programs.*`, `home.packages`, dotfiles...).
- `home.persistence` only matters with impermanence: it keeps the app's settings
  across reboots.

Use it by adding `blender` to your host's `default.nix`, or to a bundle in
`modules/bundles.nix`. Several files can add to the same aspect: every file in
`modules/desktop` adds to `desktop`.

## Write a bundle

A bundle is an aspect that imports other aspects, in `modules/bundles.nix`:

```nix
creative.imports = [
  blender
  obs-studio
];
```

## Values

Settings shared across files (username, locale, git identity...) live in
`config.var`, set in your host's `_variables.nix`. The theme (colors, fonts,
gaps) is in `config.theme` and `config.lib.stylix.colors`.
