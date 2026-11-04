{
  pkgs,
  src,
}:
pkgs.buildNpmPackage {
  pname = "quartz";
  version = (pkgs.lib.importJSON "${src}/package.json").version;
  inherit src;

  npmDeps = pkgs.importNpmLock {npmRoot = src;};
  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  dontNpmBuild = true;
  # The CLI bundles quartz.config.ts with esbuild on every build, and upstream
  # lists esbuild as a devDependency.
  dontNpmPrune = true;

  nativeBuildInputs = [pkgs.autoPatchelfHook];
  buildInputs = [pkgs.stdenv.cc.cc.lib];

  meta = {
    description = "Static site generator for Obsidian vaults";
    homepage = "https://quartz.jzhao.xyz";
    mainProgram = "quartz";
  };
}
