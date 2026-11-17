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
  aspects,
  config,
  ...
}: let
  inherit (config.flake.lib) mime;
in {
  flake.modules.nixos.blender = {
    imports = [aspects.home-manager];

    home-manager.sharedModules = [
      ({pkgs, ...}: {
        home.packages = [pkgs.blender];

        xdg.mimeApps = mime.defaultFor "blender.desktop" ["application/x-blender"];

        home.persistence."/persist".directories = [".config/blender"];
      })
    ];
  };
}
```

- `flake.modules.nixos.<name>` is the system side, anything you'd write in
  `configuration.nix` (services, system packages, hardware...).
- `imports` lists the aspects this one needs, so it works on any host that
  picks it, even without a bundle.
- `home-manager.sharedModules` is the user side, anything you'd write in a
  home-manager config (`programs.*`, `home.packages`, dotfiles...).
- `mime.defaultFor` makes the app the default for those file types
  (`mime.types` has the usual groups: `image`, `video`, `pdf`...).
- `home.persistence` only matters on hosts with the `impermanence` aspect: it
  keeps the app's settings across reboots.

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

Values shared across files are typed options, set by each host in its
`default.nix`:

- `nixeljam.username` and `nixeljam.configDirectory` (`modules/hosts/common.nix`)
- `nixeljam.git.name` and `nixeljam.git.email` (`modules/programs/dev/git.nix`)
- `nixeljam.server.*` for the self-hosted services (`modules/hosts/common.nix`)

Everything else is a plain NixOS option: `networking.hostName`, `time.timeZone`,
`services.xserver.xkb.layout`... Shared aspects set them with `lib.mkDefault`,
so a host just sets its own value. From home-manager, read them through
`osConfig`. The theme (colors, fonts, gaps) is in `config.theme` and
`config.lib.stylix.colors` (`osConfig.theme` from home-manager), and
`pkgs.unstable` has the same packages from nixos-unstable.
