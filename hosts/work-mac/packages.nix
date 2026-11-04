{pkgs, ...}: {
  home.packages = with pkgs; [
    beancount
    btop
    chezmoi
    duti
    fastfetch
    ffmpeg
    gh
    kotlin
    nmap
    stow
    yt-dlp

    ripgrep
    fd
    jq
    tree
    wget
    curl
    htop
    ncdu

    gh-dash
    httpie
    imagemagick
    chafa
    tealdeer
    jless
    figlet
    pastel
    glow
    hexyl
    exiftool
  ];
}
