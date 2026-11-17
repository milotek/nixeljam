{lib}:
# Returns a NixOS module (attrset), to be used in `imports`.
#
# Options:
#   internet          - allow outbound internet access via NAT (default: false),
#                       the host sets its WAN interface in networking.nat.externalInterface
#   bindMounts        - host paths to mount into the container (see containers.<name>.bindMounts)
#   config            - NixOS module for the container
let
  nginxHardening = {config, ...}:
    lib.mkIf config.services.nginx.enable {
      services.nginx.serverTokens = false;
    };
in {
  mkContainer = {
    name,
    hostIp,
    containerIp,
    internet ? false,
    bindMounts ? {},
    nixosConfig,
  }:
    assert lib.assertMsg (lib.stringLength "ve-${name}" <= 15)
    "mkContainer: interface name 've-${name}' is ${toString (lib.stringLength "ve-${name}")} chars, max is 15";
      {
        containers.${name} = {
          autoStart = true;
          privateNetwork = true;
          hostAddress = hostIp;
          localAddress = containerIp;
          inherit bindMounts;
          config = {...}: {
            imports = [
              nixosConfig
              nginxHardening
            ];
            networking.nameservers = lib.mkIf internet [
              "${hostIp}"
            ];
          };
        };
      }
      // (lib.optionalAttrs internet {
        # Without it, NixOS masquerades out of every interface instead of failing
        imports = [
          ({config, ...}: {
            assertions = [
              {
                assertion = config.networking.nat.externalInterface != null;
                message = "mkContainer: ${name} needs internet, set networking.nat.externalInterface to the host's WAN interface";
              }
            ];
          })
        ];
        boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkDefault true;
        networking.nat = {
          enable = true;
          internalInterfaces = ["ve-${name}"];
        };
        # CONTAINER-FWD (defined by another module) blocks all forwarding by default.
        # Insert rules in FORWARD before it: allow return traffic, block LAN, allow internet.
        networking.firewall.extraCommands = ''
          iptables -I FORWARD 1 -s ${containerIp} -m conntrack --ctstate NEW -j ACCEPT
          iptables -I FORWARD 1 -s ${containerIp} -d 192.168.0.0/16 -j DROP
          iptables -I FORWARD 1 -s ${containerIp} -d 172.16.0.0/12 -j DROP
          iptables -I FORWARD 1 -s ${containerIp} -d 10.0.0.0/8 -j DROP
          iptables -I FORWARD 1 -d ${containerIp} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
        '';
        networking.firewall.extraStopCommands = ''
          iptables -D FORWARD -s ${containerIp} -m conntrack --ctstate NEW -j ACCEPT 2>/dev/null || true
          iptables -D FORWARD -s ${containerIp} -d 192.168.0.0/16 -j DROP 2>/dev/null || true
          iptables -D FORWARD -s ${containerIp} -d 172.16.0.0/12 -j DROP 2>/dev/null || true
          iptables -D FORWARD -s ${containerIp} -d 10.0.0.0/8 -j DROP 2>/dev/null || true
          iptables -D FORWARD -d ${containerIp} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
        '';
      });
}
