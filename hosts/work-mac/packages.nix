{pkgs, ...}: {
  home.packages = with pkgs; [
    beancount
    btop # aliased `larpmaxx`
    chezmoi
    duti
    fastfetch # aliased `larp`
    ffmpeg
    gh
    kotlin
    nmap
    stow
    yt-dlp # used by the `dl` function

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
