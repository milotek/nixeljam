{pkgs, ...}: {
  home.packages = with pkgs; [
    # I love TUIs
    caligula # User-friendly, lightweight TUI for disk imaging (ISO, USB BOOT)
    tealdeer # Fast tldr client
    sttr # A minimalist CyberChef-like, cross-platform CLI app for performing various operations on strings
    slides # A terminal-based presentation tool that allows you to create and deliver presentations directly from the command line
    pom # Pomodoro timer in your terminal
    tabiew # A terminal-based CSV viewer and manipulator
    jless # A pager for JSON
    dua # Tool to conveniently learn about the disk usage of directories
    lazyjournal # TUI for journalctl
    mcat # Cat command for documents / images / videos and more
    vhs # Create GIF from the command-line
    pkgs.nur.repos.anotherhadi.monitui # Edit hyprland's monitor configuration
    pkgs.nur.repos.anotherhadi.fztea # Flipper Zero from the terminal
    pkgs.nur.repos.anotherhadi.usbguard-tui # TUI for managing USBGuard rules
    pkgs.nur.repos.anotherhadi.settuings # Terminal based settings (wifi, bluetooth, audio, ...)

    # I love CLIs
    httpie # Command-line HTTP client, a user-friendly cURL replacement
    proton-vpn-cli
    gh # GitHub
    figlet # Transform text into ASCII art
    pastel # Command-line tool to generate, analyze, convert and manipulate colors
    imagemagick # Image manipulation tool
    chafa # Image to ANSI/Unicode converter and more.

    # Just cool
    smassh # typing test, 10fastfinger like
    tty-solitaire
    bastet
    peaclock
    cbonsai
    pipes
    cmatrix
    fastfetch
  ];
}
