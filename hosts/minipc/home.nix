# minipc: same graphical profile as the pc. Monitors are auto-detected, so
# there are no machine-specific overrides beyond variables/secrets.
{...}: {
  imports = [
    ../../home/graphical.nix

    ./variables.nix
    ./secrets
  ];
}
