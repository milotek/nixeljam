{
  pkgs,
  lib,
  ...
}: let
  archWikiSrc = pkgs.fetchurl {
    url = "https://github.com/filiparag/wikiman/releases/download/2.14.1/arch-wiki_20260810.source.tar.xz";
    hash = "sha256-82aiDvwZ07m9CfBVYIDLSUpWds4QxUbCbCPmQ26j1XI=";
  };
  tldrPagesSrc = pkgs.fetchurl {
    url = "https://github.com/filiparag/wikiman/releases/download/2.14.1/tldr-pages_20260810.source.tar.xz";
    hash = "sha256-2vdszVMImSN1UF+OepKdj1v+lsG2jM68gcpnUJyqddw=";
  };

  # Real files, not symlinks: wikiman detects sources with `find -type f`.
  data = pkgs.runCommand "wikiman-data" {nativeBuildInputs = [pkgs.xz];} ''
    mkdir -p $out
    cp -r ${pkgs.wikiman}/share $out/share
    chmod -R u+w $out/share
    tar xf ${archWikiSrc} -C $out --strip-components=1
    tar xf ${tldrPagesSrc} -C $out --strip-components=1
  '';

  wikiman-full = pkgs.symlinkJoin {
    name = "wikiman-full";
    paths = [pkgs.wikiman];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      rm $out/bin/wikiman
      makeWrapper ${pkgs.wikiman}/bin/.wikiman-wrapped $out/bin/wikiman \
        --prefix PATH : "${lib.makeBinPath [pkgs.fzf pkgs.ripgrep pkgs.gawk pkgs.w3m pkgs.coreutils pkgs.parallel]}" \
        --set conf_sys_usr "${data}"
    '';
    meta.mainProgram = "wikiman";
  };
in {
  home.packages = [wikiman-full];
}
