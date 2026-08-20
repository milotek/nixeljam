{
  pkgs,
  ...
}: {
  # Your actual ~/.p10k.zsh, copied into the repo so it is declarative.
  home.file.".p10k.zsh".source = ./p10k.zsh;

  home.sessionPath = ["$HOME/go/bin"];
  home.sessionVariables = {
    COLORTERM = "truecolor";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Shell helpers (also aliased below)
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  programs.eza.enable = true;
  programs.bat.enable = true;
  programs.yazi.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      ignoreDups = true;
      save = 10000;
      size = 10000;
    };

    # oh-my-zsh for plugins you already use. Autosuggestions + syntax highlighting
    # are provided natively above, so they are not listed as omz plugins.
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "history"];
    };

    # powerlevel10k prompt (loaded as a plugin; configured by ~/.p10k.zsh).
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = {
      # editor / navigation
      vim = "nvim";
      vi = "nvim";
      v = "nvim";
      cd = "z";
      ls = "eza --icons=always --no-quotes";
      tree = "eza --icons=always --tree --no-quotes";
      cat = "bat --paging=never --plain";
      mkdir = "mkdir -p";
      c = "clear";
      e = "exit";

      # git
      g = "lazygit";
      ga = "git add";
      gaa = "git add .";
      gc = "git commit";
      gcm = "git commit -m";
      gp = "git push";
      gpl = "git pull";
      gs = "git status";
      gd = "git diff";
      gco = "git checkout";
      gcb = "git checkout -b";

      # your personal aliases (from ~/.zshrc)
      larp = "fastfetch";
      larpmaxx = "btop";
      ct = "ssh milotek.c.googlers.com";
      test = "echo tickles";

      # typos
      clera = "clear";
      celar = "clear";
      claer = "clear";
      sl = "ls";
    };

    initContent = ''
      # Powerlevel10k instant prompt — keep near the top.
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      bindkey -e

      # Suffix aliases — open by extension.
      alias -s {nix,md,txt,json,yml,yaml,go}=nvim

      # Global aliases (macOS-adapted: pbcopy instead of wl-copy).
      alias -g G="| grep"
      alias -g L="| less"
      alias -g H="| head"
      alias -g T="| tail"
      alias -g JQ="| jq"
      alias -g C="| pbcopy"
      alias -g NE="2>/dev/null"
      alias -g ND=">/dev/null"

      # Named directory shortcuts (~dl, ~ni, ...).
      hash -d dl=~/Downloads
      hash -d ni=~/.config/nixos

      # ── Your functions (from ~/.zshrc) ──
      # vs: word-diff two strings
      vs() { git diff --no-index --word-diff <(echo "$1") <(echo "$2"); }
      # dl: download media via yt-dlp (optional 2nd arg = format)
      dl() { if [ -z "$2" ]; then yt-dlp "$1"; else yt-dlp -f "$2" "$1"; fi; }
      # ul: upload a file to catbox.moe and copy the URL
      ul() { LC_ALL=C curl -s -F "reqtype=fileupload" -F "userhash=dd880b5205f68cf0614c39a0d" -F "fileToUpload=@$1" https://catbox.moe/user/api.php | pbcopy; pbpaste; echo ""; }

      # Startup banner (matches your current shell).
      fastfetch

      # ── Corp-internal aliases left commented; re-enable/adjust as needed ──
      # alias rw="rw milotek.c.googlers.com"
      # alias ws="jj jjd"
      # alias gemini='/google/bin/releases/gemini-cli/tools/gemini'

      # Source p10k config.
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';
  };
}
