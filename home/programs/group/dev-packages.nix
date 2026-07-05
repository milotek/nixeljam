{
  pkgs,
  pkgs-stable,
}:
(with pkgs; [
  go
  claude-code
  godot
])
++ (with pkgs-stable; [
  nodejs
  air
  duckdb
  python3
  jq
  nix-prefetch-github
  rsync
])
