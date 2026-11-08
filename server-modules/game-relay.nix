{lib, ...}: let
  minipc = "100.85.180.11";
  shitbox = "100.108.183.51";

  wan = "enp0s6";

  ranges = [
    {
      from = 2456;
      to = 2458;
      dest = minipc;
    }
    {
      from = 7777;
      to = 7787;
      dest = minipc;
    }

    # NetherNet ICE uses the whole advertised range; don't narrow to 19132-19133.
    {
      from = 19132;
      to = 19141;
      dest = shitbox;
    }
    {
      from = 25565;
      to = 25575;
      dest = minipc;
    }
    {
      from = 27015;
      to = 27030;
      dest = minipc;
    }
    {
      from = 28015;
      to = 28016;
      dest = minipc;
    }
  ];

  # networking.firewall rejects attrs other than from/to.
  portRanges = map (r: {inherit (r) from to;}) ranges;

  spec = r: "${toString r.from}:${toString r.to}";

  dnat = proto: r: "iptables -t nat -A GAME-RELAY -i ${wan} -p ${proto} --dport ${spec r} -j DNAT --to-destination ${r.dest}";
  snat = proto: r: "iptables -t nat -A GAME-RELAY-SNAT -o tailscale0 -p ${proto} -d ${r.dest} --dport ${spec r} -j MASQUERADE";

  bothProtos = rule: lib.concatMap (r: map (proto: rule proto r) ["udp" "tcp"]) ranges;
in {
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;

  networking.firewall = {
    allowedUDPPortRanges = portRanges;
    allowedTCPPortRanges = portRanges;

    # Dedicated flushed chains: appending to PREROUTING/POSTROUTING leaks rules on reload.
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
