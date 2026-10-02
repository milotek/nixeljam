# Relays game-server traffic from this VPS to whichever box hosts the game,
# across the tailnet.
#
# Caddy cannot carry any of this: game servers speak raw UDP/TCP, not HTTP.
# Players connect to <anything>.<domain>:<port> — every name under the wildcard
# resolves to this host, so the hostname is cosmetic and the port is what picks
# the game.
#
# Both halves of the NAT are needed. DNAT alone rewrites the destination, but
# the game server would then answer the player directly from its own default
# route; the player drops that reply because it came from an address it never
# contacted. Masquerading on the way out makes the replies come back through
# here, which is the only path the player will accept.
{lib, ...}: let
  minipc = "100.85.180.11";

  # Not in the flake and not reachable from the internet: the home line is
  # double NATted behind the ISP's own router, so a port forward on the Asus
  # never sees inbound traffic. Relaying through here is the only ingress its
  # game servers have.
  shitbox = "100.108.183.51";

  wan = "enp0s6";

  # The ranges the common engines allocate from, rather than a list of games:
  # which game sits on which port is decided in the panel, so relaying the
  # whole range means adding one is never a rebuild here. A relayed port is not
  # an open service — anything outside a live allocation reaches a minipc with
  # nothing listening on it.
  #
  # TCP beside UDP is what most of these use for RCON, which is plaintext: the
  # password crosses the wire in the clear to whoever finds the port. srcds
  # bans for 15 min after 3 failures in 30s, which is the only thing limiting a
  # guessing attack.
  ranges = [
    {
      from = 2456;
      to = 2458;
      dest = minipc;
    } # Valheim
    {
      from = 7777;
      to = 7787;
      dest = minipc;
    } # Unreal-engine family, Terraria, Satisfactory

    # Wider than the 19132-19133 Bedrock defaults because NetherNet gathers ICE
    # candidates across the whole advertised range, and the server publishes
    # this host's address as that range to the signalling service. Narrowing it
    # strands candidates outside the forward.
    {
      from = 19132;
      to = 19141;
      dest = shitbox;
    } # Minecraft Bedrock
    {
      from = 25565;
      to = 25575;
      dest = minipc;
    } # Minecraft Java
    {
      from = 27015;
      to = 27030;
      dest = minipc;
    } # Source engine
    {
      from = 28015;
      to = 28016;
      dest = minipc;
    } # Rust
  ];

  # networking.firewall rejects an attrset carrying anything but from/to.
  portRanges = map (r: {inherit (r) from to;}) ranges;

  spec = r: "${toString r.from}:${toString r.to}";

  # --to-destination without a port leaves the destination port alone, so a
  # single rule carries a whole range.
  dnat = proto: r: "iptables -t nat -A GAME-RELAY -i ${wan} -p ${proto} --dport ${spec r} -j DNAT --to-destination ${r.dest}";
  snat = proto: r: "iptables -t nat -A GAME-RELAY-SNAT -o tailscale0 -p ${proto} -d ${r.dest} --dport ${spec r} -j MASQUERADE";

  bothProtos = rule: lib.concatMap (r: map (proto: rule proto r) ["udp" "tcp"]) ranges;
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  networking.firewall = {
    allowedUDPPortRanges = portRanges;
    allowedTCPPortRanges = portRanges;

    # Rules live in dedicated chains that are flushed on every apply. Appending
    # straight to PREROUTING/POSTROUTING leaks: a reload re-runs extraCommands
    # without running extraStopCommands, and dropping a range from `ranges`
    # also drops the rule that would have deleted it — so it survives until
    # reboot.
    extraCommands = lib.concatStringsSep "\n" ([
        "iptables -t nat -N GAME-RELAY 2>/dev/null || true"
        "iptables -t nat -N GAME-RELAY-SNAT 2>/dev/null || true"
        "iptables -t nat -F GAME-RELAY"
        "iptables -t nat -F GAME-RELAY-SNAT"
        "iptables -t nat -C PREROUTING -j GAME-RELAY 2>/dev/null || iptables -t nat -A PREROUTING -j GAME-RELAY"
        "iptables -t nat -C POSTROUTING -j GAME-RELAY-SNAT 2>/dev/null || iptables -t nat -A POSTROUTING -j GAME-RELAY-SNAT"
      ]
      ++ bothProtos dnat
      ++ bothProtos snat);

    extraStopCommands = lib.concatStringsSep "\n" [
      "iptables -t nat -F GAME-RELAY 2>/dev/null || true"
      "iptables -t nat -F GAME-RELAY-SNAT 2>/dev/null || true"
    ];
  };
}
