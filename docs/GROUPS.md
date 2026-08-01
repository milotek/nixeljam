# Groups

Groups are curated sets of packages exposed as flake outputs.

- **`packages.<group>`** — standalone environment for `nix shell`

## Available groups

- dev (go, bun, air, ...)
- cybersecurity (nmap, john, dirb, ffuf, ...)

Inside this config, the Cybersecurity home-manager import also sets up:

- `~/Cyber/wordlists/` with SecLists, fuzz4bounty, and hashcat rules
- `~/Cyber/tmp/` as a temporary workspace

## Quick shell without installing

```sh
nix shell github:milotek/nixeljam#cybersecurity
nix shell github:milotek/nixeljam#dev
```

This drops you into a shell with all tools in `PATH`.
No home-manager required, and no wordlists or systemd units are installed.

## Use in another flake

Add this repo as an input:

```nix
inputs.nixeljam.url = "github:milotek/nixeljam";
```

Expose a package from the input, for example in a dev shell:

```nix
{ inputs, pkgs, ... }: {
  devShells.x86_64-linux.default = pkgs.mkShell {
    packages = [ inputs.nixeljam.packages.x86_64-linux.dev ];
  };
}
```
