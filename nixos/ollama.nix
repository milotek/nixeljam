{
  config,
  pkgs,
  ...
}: {
  services.ollama = {
    enable = true;

    # Nothing here is authenticated, and the tailnet counts as a network.
    host = "127.0.0.1";

    # ollama-cuda is not in cache.nixos.org, so selecting it turns every
    # rebuild that touches this file into a multi-hour local CUDA build.
    # Vulkan is cached, accelerates on the Nvidia card, and falls back to CPU
    # elsewhere rather than failing to build.
    package = pkgs.ollama-vulkan;

    # home/programs/tui/opencode reads this back out of osConfig, so the
    # provider menu cannot offer a model the host has not pulled.
    loadModels = ["gemma3:4b"];

    # The KV cache for the full window is allocated up front, so this is a
    # memory commitment, not just a ceiling - hence per-host rather than fixed.
    environmentVariables.OLLAMA_CONTEXT_LENGTH =
      toString (config.var.ollamaContextLength or 8192);
  };
}
