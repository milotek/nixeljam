# SERVER

## Overview

This document describes the architecture and setup of the self-hosted NixOS hosts.
The `server` host is primarily accessed through Cloudflare Tunnel.
The `vps` host exposes public HTTPS entry points with Caddy and also terminates reverse SSH tunnels from private machines.

![server dashboard](../.github/assets/server_dashboard.png)

## Why This Setup?

- **Private & Secure**: Most services are only accessible through Cloudflare's access control, preventing direct exposure to the public internet.
- **Domain-based Access**: Custom domains map to services and tunnels, making access simple and consistent.
- **Modular & Declarative**: Everything is managed through NixOS modules except external access-control settings, keeping the setup reproducible.
- **Reverse Tunnels**: Private machines can expose selected local ports through the VPS without opening inbound ports at home.

## VPS Services

The `vps` host imports `server-modules/caddy.nix` and `server-modules/copyparty.nix`.

- **Caddy**: Reverse proxy for public HTTPS services on `files.<domain>` and `remote.pc.<domain>`.
- **Copyparty**: Browser-accessible file server at `files.<domain>`.
  It serves `/var/lib/copyparty` at the webroot, with `milotek` as the read-write account and `guest` as read-only.
- **Remote Desktop Frontend**: Caddy fronts the PC's noVNC service at `remote.pc.<domain>` with basic auth.
- **Reverse SSH Tunnel Endpoint**: The PC reverse tunnel may bind public SSH port `2222` and private noVNC port `localhost:6080`.
- **Security related stuff**: Caddy TLS, Fail2Ban, SSH restrictions, and firewall rules.

## Remote Desktop

The `pc` host imports `home/system/remote-desktop` and `nixos/reverse-tunnel.nix`.
`wayvnc` mirrors the active Hyprland session on `127.0.0.1:5900`.
`websockify` serves noVNC on `127.0.0.1:6080`.
The reverse tunnel forwards that local noVNC port to `localhost:6080` on the VPS, where Caddy publishes it as `https://remote.pc.<domain>`.

Remote desktop only works while the user is logged into Hyprland because `wayvnc` mirrors the running compositor session.

## Server Host Services

The `server` host imports the broader internal-service stack:

- **AdGuard Home**: A self-hosted DNS ad blocker for network-wide ad and tracker filtering.
- **Glance**: An awesome dashboard! (See the screenshot above)
- **Arr Stack (Radarr, Sonarr, etc.)**: Automated media management tools for handling movies and TV shows.
- **Mealie**: A self-hosted recipe manager and meal planner with a clean user interface.
- **Stirling-PDF**: A powerful, locally hosted web application for editing, merging, and converting PDF files.
- **CyberChef**: The "Cyber Swiss Army Knife" for data analysis, decoding, and encryption tasks.
- **Mazanoke**: A utility service for image processing, specialized in format conversion and downgrading/optimization.
- **Gitea**: Self-hosted Git service.
- **Umami**: Self-hosted analytics.
- **Blog, Wallpapers, IKnowYou, and Default Creds**: Additional small web services.
- **SSH**: Secure remote access configuration for server management.
- **Security related stuff**: Cloudflared, Fail2Ban, firewall rules, and kernel hardening.
