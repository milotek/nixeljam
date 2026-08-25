# Local inference backing opencode's `ollama/*` models.
#
# Runs as a normal service from boot. It sits idle at a few MB of RSS until
# something talks to it, and unloads models from VRAM five minutes after the
# last request, so it costs a gaming desktop essentially nothing between uses.
{pkgs, ...}: {
  services.ollama = {
    enable = true;

    # Loopback only. Nothing here is authenticated, and the tailnet counts as
    # a network.
    host = "127.0.0.1";

    # Vulkan, not CUDA: ollama-cuda is not in cache.nixos.org, so selecting it
    # turns every rebuild that touches this file into a multi-hour local CUDA
    # build. Vulkan is cached and accelerates on this machine's Nvidia GPU.
    package = pkgs.ollama-vulkan;

    # Pulled by ollama-model-loader.service on boot, so there is no manual
    # `ollama pull` step. home/programs/tui/opencode reads this list back out
    # of osConfig, so the provider menu cannot offer a model the host lacks.
    loadModels = ["qwen3.6:35b"];

    # Ollama defaults to a 4096-token window, which truncates any real coding
    # session. Raise this only as far as VRAM allows - the KV cache for the
    # full window is allocated up front.
    environmentVariables.OLLAMA_CONTEXT_LENGTH = "32768";
  };
}
