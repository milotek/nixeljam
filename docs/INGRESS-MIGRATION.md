# Ingress migration plan

Reworking how services on `pc` and `minipc` become reachable from outside the house.

## Why

The VPS going down took every public service with it, but the VPS is not the wrong idea.
The wrong idea is the transport: a hand-rolled `ssh -R` loop in `nixos/reverse-tunnel.nix`, one systemd unit per forwarded port, gated on a sops secret that has to be provisioned before the tunnel can even start.

Tailscale already solves NAT traversal, reconnection and key rotation.
Once the tailnet is up, the VPS has a route to `minipc` that is not SSH, and roughly 100 lines of custom plumbing become unnecessary.

## Decisions

| Question | Decision |
| --- | --- |
| Ingress | Keep the VPS and Caddy. Not moving to Cloudflare Tunnel. |
| DNS | Stays on Porkbun. `*.tek.rip` already wildcards to the VPS, so new services need no DNS work. |
| VPS to home transport | Tailscale, replacing the reverse SSH tunnel. |
| Remote access | SSH and noVNC over the tailnet only. No public SSH ports. |
| Registry abstraction | Rejected. See below. |
| Containers | Out of scope. |

### Why not Cloudflare Tunnel

It is HTTP-only ingress in practice.
Arbitrary TCP works only for clients running `cloudflared access tcp` locally, so a public game server would need Cloudflare Spectrum, which starts at the Pro plan and is locked to port 25565 on Pro and Business.
Free and Pro also cap proxied request bodies at 100 MB, which is a functional regression for copyparty.
Owning a public IP avoids all of that, plus the ToS 2.8 grey area on streaming music through their proxy, plus a third party terminating TLS on a personal file server.

### Why no registry

An earlier draft proposed a shared registry file that generated the Caddy vhosts, the tunnel forwards and the firewall ports from one declaration.
That was solving a problem this plan deletes.

The three-places problem exists because exposure is split across `caddy.nix`, the per-host `custom.reverseTunnel` forwards, and the VPS firewall list.
Dropping the reverse tunnel removes the second, and closing the public ports removes the third.
What remains is four vhosts in one file, which is already a single source of truth.

The only genuine repetition left is minipc's tailnet address across a handful of vhosts, which is a `let` binding, not an architecture.

## Target architecture

```
Internet
  -> *.tek.rip (Porkbun wildcard A) -> VPS public IP
  -> Caddy on the VPS (TLS via Let's Encrypt HTTP-01)
  -> tailnet -> minipc:3923 / :4533 / :5030 / :8123

Admin
  -> tailnet -> any host directly (ssh, noVNC), no public port

Raw TCP (future game servers)
  -> VPS firewall port -> nftables DNAT -> tailnet -> origin host
```

## Current state

| Host | Tailnet | Notes |
| --- | --- | --- |
| minipc | `100.85.180.11` | Was already joined. `--accept-dns=false` applied 2026-08-25. |
| pc | `100.96.10.65` | Joined 2026-08-25. |
| vps | `100.117.236.50` | Joined 2026-08-25. |

Phase 0 gate passed: vps to minipc is a direct path at 11ms, not DERP-relayed.
`tailscale ping` initially reported "direct connection not established" on the first attempt because NAT traversal had not completed yet, which is not a failure.

Verified that the firewall model works as assumed: slskd binds `*:5030` and is reachable over the tailnet but refused over the LAN, so `trustedInterfaces = ["tailscale0"]` is what scopes a wildcard-bound service.
Phase 1 therefore binds services to `0.0.0.0` rather than to a literal `100.x` address, which avoids a boot race against tailscale0 acquiring its address and survives a tailnet IP ever changing.

### Deploy drift

Neither server has been rebuilt from current main, so switching either applies accumulated changes alongside this work.

| Host | At | Behind |
| --- | --- | --- |
| pc | `8f5eee0e` | current |
| minipc | `db55fae8` | 3 commits |
| vps | `9021ff3` | predates the Phase 4 vps work |

Deploy order matters: **minipc before vps**.
Caddy starts proxying to `100.85.180.11:<port>` the moment the VPS switches, and those ports are still loopback-bound until minipc switches, so the reverse order gives a window of 502s.

`--accept-dns=false` matters on minipc specifically.
Its `/etc/resolv.conf` pointed at MagicDNS (`100.100.100.100`), which made the box that is supposed to *be* the network's DNS server depend on tailscaled for its own resolution.
That is the recorded "MagicDNS dead so fetches fail" incident.
It now resolves via the router at `192.168.50.1` directly.

This was applied at runtime with `tailscale set`, so it must also be declared or it will not survive a fresh install:

```nix
# nixos/tailscale.nix
services.tailscale.extraUpFlags = ["--accept-dns=false"];
```

## Status as of 2026-08-25 03:20

Phases 0 and 1 are **done and verified live**. Phases 2 to 4 are not started.

minipc and vps both run generation `26.05.20260811.70cc455` built from `388808a2`.
Caddy proxies to `100.85.180.11:<port>` over the tailnet, confirmed by `files` 200, `music` 302, `slsk` 200, `home` 200.
The reverse tunnel is still running but is no longer in the path for HTTP; it is the rollback route until Phase 2.
`remote.pc.tek.rip` is gone as intended.

**pc was deliberately not switched.** Its `nixos/tailscale.nix` and `remote-desktop` changes are committed but not applied,
so noVNC still binds `127.0.0.1` and the desktop is currently unreachable both publicly and over the tailnet.
The tree had unrelated in-flight work in it (`flake.nix`, `skills.nix`, `zellij`, both `home.nix`, a new `pkgs/tidyname`),
and a switch would have built all of it. Rebuild pc once that work is settled.

### Two failures worth not repeating

The first minipc rebuild was **OOM-killed** (SIGKILL) building `hermes-tui` and `web` from source.
minipc has 7.6G RAM and `nix.settings` defaults of `max-jobs = 4`, `cores = 0`, so four builds each took all four cores
on a box already holding 3.1G of Home Assistant, Navidrome, slskd and two agents.
It succeeded on retry with `--max-jobs 1 --cores 3`.

`hosts/minipc/hardware-configuration.nix` declares `swapDevices = [ ]`, but a fully allocated 8G `/swapfile`
was sitting on disk unreferenced and never activated. It was enabled by hand during this work, which is **not persistent**.
Either declare it or set `zramSwap.enable = true`, and consider `nix.settings.max-jobs = 2` on that host.

The VPS was never cut over to the v6 repo. Its checkout was on the pre-migration lineage, 1576 commits with no shared
ancestry with `origin/main`, which is why `git pull` refused. Those commits are preserved on a local branch
`pre-v6-history` **on the VPS only** and are not on GitHub. Decide whether to push or discard them.

## Phases

### Phase 0: bring Tailscale up (done)

`tailscale up --accept-dns=false` on each host, approving the device in the admin console.

Gate: `tailscale ping` succeeds in both directions between vps and minipc, and vps and pc.
Nothing below is safe until this holds, because the later phases remove the public SSH ports that are currently the only way into minipc.

### Phase 1: move Caddy onto the tailnet

Point each vhost in `server-modules/caddy.nix` at `<minipc tailnet ip>:<port>` instead of `localhost:<port>`.

Services on minipc bind `127.0.0.1` today because the tunnel was their only consumer, so each needs to move to the tailnet address.
`nixos/tailscale.nix` already sets `trustedInterfaces = ["tailscale0"]`, so this opens nothing to the LAN.

| Service | Current | Needs |
| --- | --- | --- |
| copyparty | `-i 127.0.0.1` | bind tailnet IP |
| navidrome | `Address = "127.0.0.1"` | bind tailnet IP |
| slskd | `web.port` on loopback | bind tailnet IP |
| home-assistant | `server_host = "127.0.0.1"` | bind tailnet IP **and** add the VPS tailnet IP to `trusted_proxies` |

Home Assistant's `trusted_proxies` currently lists `127.0.0.1` and `::1`, which stops being true the moment Caddy is on another machine.
This one fails as a silent 400, not an obvious error.

Gate: every service loads over its public hostname with the tunnel units manually stopped.

### Phase 2: delete the reverse tunnel

With Caddy proven on the tailnet path, remove:

- `nixos/reverse-tunnel.nix`
- the `custom.reverseTunnel` blocks in `hosts/pc/configuration.nix` and `hosts/minipc/configuration.nix`
- the `reverse-tunnel-key` secret from both hosts' `secrets/system-secrets.yaml`
- `services.openssh.settings.GatewayPorts` on the VPS, which existed only so tunnels could bind public ports

### Phase 3: remote access to Tailscale only

Delete the `remote.pc.tek.rip` vhost and its bcrypt basic auth from `caddy.nix`.
Close ports 2222 and 2223 in the VPS firewall, leaving 80 and 443.

`home/system/remote-desktop/default.nix` needs updating.
wayvnc and websockify both bind `127.0.0.1` because the tunnel was the only consumer; they now need the tailnet address.
The header comment describing Caddy fronting it at `remote.<host>.<domain>` becomes wrong and should say the desktop is reachable at `http://<pc tailnet ip>:6080` from any tailnet device.

Losing the basic auth is a security improvement rather than a regression, since the VNC side was always unauthenticated and only protected by what sat in front of it.

Gate: `ssh milotek@<minipc tailnet ip>` works, noVNC loads over the tailnet, and a port scan of the VPS shows only 80 and 443.

### Phase 4: raw TCP, when a game server actually exists

Open the public port on the VPS and DNAT it to the origin's tailnet address via nftables, with `networking.nat` masquerading so return traffic finds its way back.
Not built until there is something to forward.

## Unrelated findings worth fixing

**AdGuard is running but not serving DNS.**
`adguardhome` is active and enabled on minipc, but nothing is listening on port 53 and the LAN resolves via the router at `192.168.50.1`.
The module never had its first-run onboarding completed at `localhost:3000`, so network-wide ad blocking is not actually happening.

**14 files under `server-modules/` reference `config.var.tunnelId`,** which no host in this fork sets.
They are dormant upstream modules that would fail to evaluate the moment one is imported.
Fix each on adoption rather than all 14 speculatively.

**`docs/SERVER.md` describes upstream's cloudflared architecture,** which this fork does not use.
Rewrite it once Phase 2 lands.

## Risks

**Phase 0 is a hard gate.**
Removing public SSH before the tailnet is verified on all three hosts means losing access to minipc entirely.
Do not compress phases into one rebuild.

**The public site gains a dependency on Tailscale's control plane.**
This trades a hand-rolled dependency for a managed one, which is the right direction, but it is not a dependency removed.

**The VPS is still the only public ingress.**
This plan does not add a second one.
It makes the ingress swappable without touching service modules, which is the useful property.
