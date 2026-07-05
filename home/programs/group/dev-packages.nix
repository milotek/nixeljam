{
  pkgs,
  pkgs-stable,
}:
(with pkgs; [
  go
  claude-code
  godot
  # rust toolchain
  rustc
  cargo
  rust-analyzer
  clippy
  rustfmt
  # python: python3 interpreter is in the pkgs-stable list below;
  # uv manages per-project virtualenvs and Python versions
  uv
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
