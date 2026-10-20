{config, ...}: {
  sops.secrets.hermes-env = {
    owner = "hermes";
    mode = "0400";
  };

  services.hermes-agent = {
    enable = true;
    container.enable = true;

    settings = {
      model.default = "anthropic/claude-opus-5";
      toolsets = ["all"];
      approvals.mode = "off";
      terminal = {
        backend = "local";
        timeout = 180;
      };
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };
    };

    environmentFiles = [config.sops.secrets.hermes-env.path];
    environment.TELEGRAM_ALLOWED_USERS = "5702116773";
    addToSystemPackages = true;
    restartSec = 30;
  };

  systemd.services.hermes-agent.serviceConfig.TimeoutStopSec = 30;

  users.users.${config.var.username}.extraGroups = ["hermes"];
}
