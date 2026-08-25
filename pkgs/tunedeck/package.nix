{pkgs}: let
  python = pkgs.python3.withPackages (ps: with ps; [requests spotipy]);

  # dbus-send drives the headless Spotify client over MPRIS; spotdl and scdl are
  # the fetchers for tracks the library does not have yet.
  runtimeDeps = pkgs.lib.makeBinPath [pkgs.dbus pkgs.spotdl pkgs.scdl];
in
  pkgs.runCommand "tunedeck" {
    nativeBuildInputs = [pkgs.makeWrapper];
    meta = {
      description = "Mirror Navidrome playback onto Spotify and sync playlists both ways";
      mainProgram = "tunedeck";
    };
  } ''
    install -Dm755 ${./tunedeck.py} $out/bin/tunedeck
    substituteInPlace $out/bin/tunedeck \
      --replace-fail '#!/usr/bin/env python3' '#!${python}/bin/python3'
    wrapProgram $out/bin/tunedeck --prefix PATH : ${runtimeDeps}
  ''
