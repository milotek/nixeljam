{
  pkgs,
  lib,
  config,
}: let
  vault = "${config.home.homeDirectory}/Projects/ObsidianVault";
  remote = "git@github.com:milotek/ObsidianVault.git";

  # Obsidian rewrites obsidian.json itself, so the vault is registered at launch
  # rather than through home.file. The obsidian-git plugin ships in the vault.
  bootstrap = pkgs.writeShellScript "obsidian-open-vault" ''
    CONFIG="$HOME/.config/obsidian/obsidian.json"

    if [ ! -e ${lib.escapeShellArg vault}/.git ]; then
      mkdir -p ${lib.escapeShellArg (builtins.dirOf vault)}
      ${lib.getExe pkgs.git} clone ${lib.escapeShellArg remote} ${lib.escapeShellArg vault} || true
    fi

    if [ -d ${lib.escapeShellArg vault} ]; then
      mkdir -p "$(dirname "$CONFIG")"
      [ -s "$CONFIG" ] || printf '{"vaults":{}}' > "$CONFIG"

      id=$(printf '%s' ${lib.escapeShellArg vault} | sha256sum | cut -c1-16)
      tmp=$(mktemp)
      ${lib.getExe pkgs.jq} \
        --arg id   "$id" \
        --arg path ${lib.escapeShellArg vault} \
        '
          .vaults //= {} |
          if (.vaults | has($id)) then . else
            .vaults = (
              (.vaults | with_entries(.value.open = false)) +
              {($id): {"path": $path, "ts": (now * 1000 | floor), "open": true}}
            )
          end
        ' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG" || rm -f "$tmp"
    fi
  '';
in
  pkgs.symlinkJoin {
    name = "obsidian-with-vault";
    paths = [pkgs.obsidian];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/obsidian \
        --prefix PATH : ${lib.makeBinPath [pkgs.git pkgs.openssh]} \
        --run ${lib.escapeShellArg (toString bootstrap)}
    '';
  }
