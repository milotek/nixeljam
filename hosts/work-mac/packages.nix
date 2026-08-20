{pkgs, ...}: {
  home.packages = with pkgs; [
    # ── From your Homebrew leaves, now via nix ──
    beancount # plain-text accounting
    btop # resource monitor (aliased `larpmaxx`)
    chezmoi # dotfile manager
    duti # set default apps by UTI (macOS)
    fastfetch # system info (aliased `larp`)
    ffmpeg # media swiss-army knife
    gh # GitHub CLI
    kotlin # Kotlin compiler
    nmap # network scanner
    stow # symlink farm manager
    yt-dlp # media downloader (used by the `dl` function)

    # ── Core CLI niceties (pc-parity, all build on macOS) ──
    ripgrep
    fd
    jq
    tree
    wget
    curl
    htop
    ncdu

    # ── TUIs / extras from your pc set that build on macOS ──
    gh-dash # GitHub dashboard TUI
    httpie # friendly HTTP client
    imagemagick # image manipulation
    chafa # images -> ANSI
    tealdeer # fast tldr client
    jless # JSON pager
    figlet # ASCII art text
    pastel # color tool
    glow # markdown renderer
    hexyl # hex viewer
    exiftool # media metadata
  ];
}
