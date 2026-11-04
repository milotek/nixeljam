{
  config,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;

    # Unauthenticated; don't expose beyond localhost.
    host = "127.0.0.1";

    # ollama-cuda is uncached and means multi-hour local builds.
    package = pkgs.ollama-vulkan;

    loadModels = ["gemma3:4b"];

    environmentVariables.OLLAMA_CONTEXT_LENGTH =
      toString (config.var.ollamaContextLength or 8192);
  };
}
