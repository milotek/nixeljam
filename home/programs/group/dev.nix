{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs-unstable;
    [
      go
      claude-code
      uv
    ]
    ++ (with pkgs; [
      nodejs
      air
      clang
      clang-tools
      cmake
      gnumake
      gdb
      duckdb
      python3
      jq
      nix-prefetch-github
      rsync
    ]);
}
