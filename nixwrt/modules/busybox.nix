nixpkgs: self: super:
  with nixpkgs;
  let busyboxArgs = { config, applets } :
    let xconfig = builtins.concatStringsSep "\n"
      (lib.mapAttrsToList (n: v: "CONFIG_${pkgs.lib.strings.toUpper n} ${toString v}") config);
        aconfig = builtins.concatStringsSep "\n"
      (map (n: "CONFIG_${pkgs.lib.strings.toUpper n} y") applets);
    in {
      enableStatic = true;
      enableMinimal = true;
      extraConfig = ''
        ${xconfig}
        ${aconfig}
      '';
    };
    s = { busybox = { config = {} ; applets = [] ; };} // super ;
  in nixpkgs.lib.attrsets.recursiveUpdate super {
      busybox = {
        applets = [
          "cat"
          "chmod"
          "chown"
          "cp"
          "dd"
          "df"
          "dmesg"
          "du"
          "find"
          "grep"
          "gzip"
          "init"
          "kill"
          "ls"
          "mkdir"
          "mount"
          "mv"
          "ping"
          "ps"
          "reboot"
          "rm"
          "rmdir"
          "stty"
          "tar"
          "umount"
          "zcat"
        ];
        config = s.busybox.config;
        package = pkgs.busybox.override (busyboxArgs {
          config = self.busybox.config ;
          applets = self.busybox.applets;
        });
      };
    }
