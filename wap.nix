# This is copy-pasted from backuphost.nix but will eventually be a
# configuration for a wireless access point based on Atheros 9331
# (testing on Arduino Yun, deploying on Trendnet TEW712BR)

{ targetBoard ? "yun" }:
let device = (import ./nixwrt/devices.nix).${targetBoard};
    modules = (import ./nixwrt/modules/default.nix);
    system = (import ./nixwrt/mksystem.nix) device;
    overlay = (import ./nixwrt/overlay.nix);
    nixpkgs = import <nixpkgs> (system // { overlays = [overlay] ;} ); in
with nixpkgs;
let
    rootfsImage = pkgs.callPackage ./nixwrt/rootfs-image.nix ;
    myKeys = (nixpkgs.stdenv.lib.splitString "\n" ( builtins.readFile "/etc/ssh/authorized_keys.d/dan" ) );
    baseConfiguration = rec {
      hostname = "uostairs";
      interfaces = {
        "eth1" = { };
        lo = { ipv4Address = "127.0.0.1/8"; };
        "wlan0" = { };
        "br0" = {
          type = "bridge";
          members  = [ "eth1" "wlan0" ];
        };
      };
      etc = {
        "resolv.conf" = { content = ( stdenv.lib.readFile "/etc/resolv.conf" );};
      };
      users = [
        {name="root"; uid=0; gid=0; gecos="Super User"; dir="/root";
         shell="/bin/sh"; authorizedKeys = myKeys;}
        {name="dan"; uid=1000; gid=1000; gecos="Daniel"; dir="/home/dan";
         shell="/bin/sh"; authorizedKeys = myKeys;}
      ];
      packages = [] ; #  [ swconfig ];
      filesystems = { };
      services = {
      };
    };
    wantedModules = with modules; [
      (nixpkgs: self: super: baseConfiguration)
      device.hwModule
      (sshd { hostkey = ./ssh_host_key ; })
      busybox
      (syslogd { loghost = "192.168.0.2"; })
      (ntpd { host = "pool.ntp.org"; })
      (hostapd {
        config = { interface = "wlan0"; ssid = "testlent"; hw_mode = "g"; channel = 1; };
        # no suport currently for generating these, use wpa_passphrase
        psk = builtins.getEnv( "PSK") ;
      })
      (dhcpClient { interface = "br0"; })
    ];
    configuration =
      with nixpkgs.stdenv.lib;
      let extend = lhs: rhs: lhs // rhs lhs;
      in lib.fix (self: lib.foldl extend {}
                    (map (x: x self) (map (f: f nixpkgs) wantedModules)));
in rec {
  kernel = configuration.kernel.package;
  swconfig = pkgs.swconfig.override { inherit kernel; };

  busybox = configuration.busybox.package;

  rootfs = rootfsImage {
    inherit busybox configuration;
    inherit (pkgs) monit iproute;
  };

  tftproot = stdenv.mkDerivation rec {
    name = "tftproot";
    phases = [ "installPhase" ];
    kernelImage = (if targetBoard == "malta" then kernel.vmlinux else "${kernel.out}/kernel.image");
    installPhase = ''
      mkdir -p $out
      cp ${kernelImage} $out/kernel.image
      cp ${rootfs}/image.squashfs  $out/rootfs.image
    '';
  };

  firmwareImage = stdenv.mkDerivation rec {
    name = "firmware.bin";
    phases = [ "installPhase" ];
    installPhase =
      let liveKernelAttrs = lib.attrsets.recursiveUpdate testKernelAttrs {
            extraConfig."CMDLINE" =
              builtins.toJSON "earlyprintk=serial,ttyS0 console=ttyS0,115200 panic=10 oops=panic init=/bin/init root=/dev/mtdblock5 rootfstype=squashfs";
          };
          kernel = pkgs.kernel.override liveKernelAttrs;
      in ''
        dd if=${kernel.out}/kernel.image of=$out bs=128k conv=sync
        dd if=${rootfs}/image.squashfs of=$out bs=128k conv=sync,nocreat,notrunc oflag=append
      '';
  };
}
