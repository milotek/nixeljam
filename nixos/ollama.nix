{ pkgs, ... }: {
  # No systemd service on purpose: ollama should NOT run in the background or
  # start at boot. This just installs the `ollama` binary.
  #
  # Start it on demand when you want to use opencode:
  #   ollama serve            # runs in the foreground; Ctrl-C to stop
  # then, the first time only, pull the model:
  #   ollama pull qwen3.6:35b
  environment.systemPackages = [ pkgs.ollama ];
}
