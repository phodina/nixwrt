{
  busybox
, buildPackages
, monit
, iproute
, stdenv
, runCommand
, writeText
, pkgs
, lib
, configuration
, ...}:
let
  monitrc = import ./monitrc.nix {
    inherit lib pkgs iproute;
    inherit (pkgs) writeScriptBin writeText;
    inherit (configuration) interfaces services filesystems;
  };
  packagesToInstall = configuration.packages ++ [
    busybox
    monit
    monitrc
    pkgs.dropbear
  ];
  dropbearHostKey = runCommand "makeHostKey" { preferLocalBuild = true; } ''
      ${buildPackages.dropbear}/bin/dropbearconvert openssh dropbear ${configuration.services.dropbear.hostKey} $out
    '';
  mkPseudoFile = import ./pseudofile.nix { inherit lib writeText ; };
  pseudoEtc = mkPseudoFile "pseudo-etc.txt" "/etc/" ({
    monitrc = {
      mode = "0400";
      content = ''
      include ${monitrc}
      '';
    };
    group = {content = ''
      root:!!:0:
    '';};
    hosts = {content = "127.0.0.1 localhost\n"; };
    fstab = {
      content = (import ./fstab.nix stdenv) configuration.filesystems;
    };
    passwd = {content = (import ./mkpasswd.nix stdenv) configuration.users; };
    inittab = {content = ''
      ::askfirst:-/bin/sh
      ::sysinit:/etc/rc
      ::respawn:${monit}/bin/monit -I -c /etc/monitrc
    '';};
    "mdev.conf" = { content = ''
      -[sh]d[a-z] 0:0 660 @${monit}/bin/monit start vol_\$MDEV
      [sh]d[a-z] 0:0 660 $/usr/bin/env ${monit}/bin/monit stop vol_\$MDEV
      null 0:0 666
      zero 0:0 666
      full 0:0 666
    ''; };
    rc = {mode="0755"; content = ''
      #!${busybox}/bin/sh
      stty sane < /dev/console
      mount -a
      mkdir /dev/pts
      mount -t devpts none /dev/pts
      echo /bin/mdev > /proc/sys/kernel/hotplug
      mdev -s
    '';};

  } // configuration.etc) ;

  # only need enough in /dev to get us to where we can mount devtmpfs,
  # this can probably be pared down
  pseudoDev = let newline = "\\n"; in pkgs.writeText "pseudo-dev.txt" ''
    /dev d 0755 root root
    /dev/console c 0600 root root 5 1
    /dev/null c 0666 root root 1 3
    /dev/tty c 0777 root root 5 0
    /dev/zero c 0666 root root 1 5
    /proc d 0555 root root
    /root d 0700 root root
    /root/.ssh d 0700 root root
    /run d 0755 root root
    /sys d 0555 root root
    /tmp d 1777 root root
    /var d 0755 root root
    ${lib.strings.concatStringsSep "\n"
       (lib.attrsets.mapAttrsToList (n: a: "${n} d 0755 root root")
         configuration.filesystems)}
    /etc/dropbear d 0700 root root
    /etc/dropbear/dropbear_rsa_host_key f 0600 root root cat ${dropbearHostKey}
    /root/.ssh/authorized_keys f 0600 root root echo -e "${builtins.concatStringsSep newline ((builtins.elemAt configuration.users 0).authorizedKeys) }"
  '';
  squashfs = import <nixpkgs/nixos/lib/make-squashfs.nix> {
    inherit (buildPackages) perl pathsFromGraph squashfsTools;
    inherit stdenv;
    storeContents = packagesToInstall ;
    compression = "xz";
    compressionFlags = "-Xdict-size 100%";
  };
in stdenv.mkDerivation rec {
  name = "nixwrt-root";
  phases = [ "installPhase" ];
  nativeBuildInputs = [ buildPackages.qprint buildPackages.squashfsTools ];
  installPhase =
    let linkFarm = p : "( cd $out/bin; for i in ${p}/bin/* ; do ln -fs $i . ; done )"; in ''
      mkdir -p $out/sbin $out/bin $out/nix/store
      touch $out/.empty
      '' + (lib.strings.concatStringsSep "\n"
              (map linkFarm packagesToInstall)) + ''
      # mksquashfs has the unhelpful (for us) property that it will
      # copy /nix/store/$xyz as /$xyz in the image
      cp ${squashfs} $out/image.squashfs
      chmod +w $out/image.squashfs
      # so we need to graft all the directories in the image back onto /nix/store
      mksquashfs $out/.empty $out/image.squashfs -root-becomes store
      mksquashfs $out/sbin $out/bin  $out/image.squashfs  \
       -root-becomes nix -pf ${pseudoDev}  -pf ${pseudoEtc}
      chmod a+r $out/image.squashfs
    '';
}
