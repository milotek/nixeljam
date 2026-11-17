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
{aspects, ...}: {
  flake.modules.nixos.blender.imports = [aspects.home-manager];
  flake.modules.nixos.blender.home-manager.sharedModules = [
    (
      {pkgs, ...}: {
        home.packages = [pkgs.blender];

        home.persistence."/persist".directories = [".config/blender"];
      }
    )
  ];
}
```

- `flake.modules.nixos.<name>` is the system side, anything you'd write in
  `configuration.nix` (services, system packages, hardware...).
- `home-manager.sharedModules` is the user side, anything you'd write in a
  home-manager config (`programs.*`, `home.packages`, dotfiles...).
- `imports` lists the aspects this one needs, here `home-manager` for `home-manager.sharedModules`.
  Importing an aspect several times is fine, it is only loaded once.
- `home.persistence` only matters on hosts with the `impermanence` aspect: it keeps the app's settings across reboots.
- An app that opens files declares it with the MIME helper from `modules/lib/mime.nix`:
  `xdg.mimeApps = mime.defaultFor "blender.desktop" ["model/x-blend"];`

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

Host settings live in your host's `_variables.nix`.
Most are plain NixOS options (`networking.hostName`, `time.timeZone`, `services.xserver.xkb.layout`...).
The others are typed `nixeljam.*` options, declared by the aspect that uses them: `nixeljam.username` and `nixeljam.configDirectory` in `modules/hosts/common.nix`, `nixeljam.extraLocale` in `modules/system/locale.nix`, `nixeljam.git` in `modules/programs/dev/git.nix`, `nixeljam.server` in `modules/server/cloudflared.nix`.
Home-manager modules read them through `osConfig`, for example `osConfig.nixeljam.git.name`.

Packages from nixos-unstable are `pkgs.unstable.<name>`.
Colors and fonts come from Stylix (`config.lib.stylix.colors`), window rounding, gaps and borders from `config.theme` (`osConfig.theme` in home-manager modules).
