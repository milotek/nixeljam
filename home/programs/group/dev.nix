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

  # Default GOPATH is ~/go, which puts a build cache in the middle of $HOME.
  home.sessionVariables.GOPATH = "$HOME/.local/share/go";
  home.sessionPath = ["$HOME/.local/share/go/bin"];
}
