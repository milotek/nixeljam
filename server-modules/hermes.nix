# Hermes Agent (Nous Research) - self-hosted autonomous AI agent.
# https://github.com/NousResearch/hermes-agent
#
# Runs the official multi-arch image (works on this aarch64 VPS) as a
# declarative Docker container. All state lives in /var/lib/hermes, which is
# bind-mounted to the container's /opt/data (config.yaml, sessions, memories,
# skills, logs). The container's internal user is `hermes` (UID 10000), so the
# host state dir is owned to match.
#
# SECURITY: this agent gets a shell, a browser, and filesystem access inside
# its container, and this VPS can reach the PC over the reverse tunnel
# (localhost:2222 SSH, localhost:6080 noVNC). That exposure is intentional per
# the operator's choice. The API server and control dashboard are bound to
# 127.0.0.1 only - reach the dashboard over an SSH tunnel rather than exposing
# it publicly:
#   ssh -i ~/.ssh/key -L 9119:localhost:9119 <user>@<vps>  ->  http://localhost:9119
#
# The model API key lives in sops as an env file:
#   sops hosts/vps/secrets/secrets.yaml   ->  hermes-env
# holding lines like:  ANTHROPIC_API_KEY=sk-ant-...
{
  config,
  pkgs,
  ...
}: {
  # Container runtime - mirror the repo's pinned Docker package.
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };
  virtualisation.oci-containers.backend = "docker";

  # Model provider key(s) as a docker --env-file. Stored as a single multiline
  # sops value; owner root because the container is launched by root's docker.
  sops.secrets.hermes-env = {
    mode = "0400";
  };

  # Host state dir, owned by the container's internal hermes user (UID/GID 10000).
  systemd.tmpfiles.rules = [
    "d /var/lib/hermes 0700 10000 10000 -"
  ];

  virtualisation.oci-containers.containers.hermes = {
    image = "nousresearch/hermes-agent:latest";
    cmd = ["gateway" "run"];
    autoStart = true;

    volumes = ["/var/lib/hermes:/opt/data"];

    # Bound to loopback only - fronted by an SSH tunnel, never the public net.
    ports = [
      "127.0.0.1:8642:8642" # OpenAI-compatible API server + health endpoint
      "127.0.0.1:9119:9119" # web dashboard
    ];

    environment = {
      HERMES_DASHBOARD = "1";
    };
    environmentFiles = [config.sops.secrets.hermes-env.path];

    # Playwright/Chromium (browser tool) needs a larger /dev/shm.
    extraOptions = ["--shm-size=1g"];
  };
}
