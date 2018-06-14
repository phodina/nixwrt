{
  mt300a = {
    name = "gl-mt300a"; endian= "little";
    kernel = lib: let adds = [
                        "CLKSRC_MMIO"
                        "CMDLINE_OVERRIDE"
                        "CMDLINE_PARTITION"
                        "DEBUG_INFO"
                        "EARLY_PRINTK"
                        "GENERIC_IRQ_IPI"
                        "IP_PNP"
                        "MIPS_CMDLINE_BUILTIN_EXTEND"
                        "MTD_CMDLINE_PART"
                        "MTD_PHRAM"
                        "NET_MEDIATEK_GSW_MT7620"
                        "NET_MEDIATEK_MT7620"
                        "PARTITION_ADVANCED"
                        "PRINTK_TIME"
                        "SOC_MT7620"
                        "SQUASHFS"
                        "SQUASHFS_XZ"
                        "SQUASHFS_ZLIB"
                        "SWCONFIG"
                      ] ;
                 removes = ["MTD_ROOTFS_ROOT_DEV" "IMAGE_CMDLINE_HACK"
                            "BLK_DEV_INITRD"];
                 others = {
                            "CPU_LITTLE_ENDIAN" = "y";
                            "CMDLINE" = builtins.toJSON "earlyprintk=serial,ttyS0 console=ttyS0,115200 panic=10 oops=panic init=/bin/init phram.phram=nixrootfs,0x2000000,11Mi root=/dev/mtdblock0 memmap=12M\$0x2000000 loglevel=8 rootfstype=squashfs";
                        }; in
    {
      defaultConfig = "ramips/mt7620/config-4.9";
      socFamily = "ramips";
      extraConfig = (lib.genAttrs adds (name: "y")) //
                    (lib.genAttrs removes (name: "n")) //
                    others;
      dts = nixpkgs: nixpkgs.stdenv.mkDerivation rec {
        name = "gl-mt300a.dts";
        version = "1";
        src = nixpkgs.buildPackages.fetchurl {
          url = "https://raw.githubusercontent.com/lede-project/source/70b192f57358f753842cbe1f8f82e26e8c6f9e1e/target/linux/ramips/dts/GL-MT300A.dts";
          sha256 = "17nc31hii74hz10gfsg2v4vz5y8k91n9znyydvbnfsax7swrzlnw";
        };
        patchFile = ./kernel/kernel-dts-enable-eth0.patch;
        phases = [ "installPhase" ];
        installPhase = ''
          cp $src ./board.dts
          echo patching from ${patchFile}
          ${nixpkgs.buildPackages.patch}/bin/patch -p1 < ${patchFile}
          cp ./board.dts $out
        '';
      };
    };
  };
  yun = { name = "arduino-yun"; endian = "big";
          kernel = lib: {
	    loadAddress = "0x80060000";
	    entryPoint = "0x80060000";
            defaultConfig = "ar71xx/config-4.9";
            socFamily = "ar71xx";
            extraConfig = {
              "ATH79_MACH_ARDUINO_YUN" = "y";
              "PARTITION_ADVANCED" = "y";
              "CMDLINE_PARTITION" = "y";
              "MTD_CMDLINE_PART" = "y";
#              "MTD_PHRAM" = "y";
              "SQUASHFS" = "y";
              "SQUASHFS_XZ" = "y";
#              "SQUASHFS_ZLIB" = "y";
              "BLK_DEV_INITRD" = "n";
              "SYSCTL_SYSCALL" = "n";
              "SYSFS_SYSCALL" = "n";
              "KALLSYMS" = "n";
              "ELF_CORE" = "n";
              "SLUB_DEBUG" = "n";
              "COMPAT_BRK" = "n";
              "MODULES" = "y";
              "AEABI" = "y";
              "AG71XX_AR8216_SUPPORT" = "y";
              "AG71XX" = "y";
              "AR8216_PHY_LEDS" = "y";
              "AR8216_PHY" = "y";
              "ARCH_HAS_DEVMEM_IS_ALLOWED" = "y";
              "ARCH_HAS_RESET_CONTROLLER" = "y";
              "ARCH_HAS_UBSAN_SANITIZE_ALL" = "y";
              "ARCH_MMAP_RND_BITS" = "8";
              "ARCH_MMAP_RND_BITS_MAX" = "16";
              "ARCH_MMAP_RND_BITS_MIN" = "8";
              "ARCH_MMAP_RND_COMPAT_BITS_MAX" = "16";
              "ARCH_MMAP_RND_COMPAT_BITS_MIN" = "8";
              "AT803X_PHY" = "y";
              "ATA_BMDMA" = "y";
              "ATAGS_PROC" = "y";
              "ATA_SFF" = "y";
              "ATH79_MACH_TEW_712BR" = "y";
              "ATH79_NVRAM" = "y";
              "ATH79_PCI_ATH9K_FIXUP" = "y";
              "ATH79_WDT" = "y";
              "ATH79" = "y";
              "BLK_DEV_LOOP_MIN_COUNT" = "8";
              "BLK_MQ_PCI" = "y";
              "CACHE_L2X0_PMU" = "y";
              "CLKDEV_LOOKUP" = "y";
              "CLS_U32_MARK" = "y";
              "COMMON_CLK" = "y";
              "CONSTRUCTORS" = "y";
              "CPU_HAS_PREFETCH" = "y";
              "CPU_HAS_RIXI" = "y";
              "CPU_MIPS32_R2" = "y";
              "CPU_MIPS32" = "y";
              "CPU_MIPSR2" = "y";
              "CPU_SUPPORTS_HIGHMEM" = "y";
              "CPU_SUPPORTS_MSA" = "y";
              "CPU_SW_DOMAIN_PAN" = "y";
              "CROSS_COMPILE" = "";
              "CRYPTO_PCRYPT" = "y";
              "DEBUG_INFO_REDUCED" = "y";
              "DEFAULT_IOSCHED" = "deadline";
              "DEFAULT_SECURITY" = "";
              "DEFAULT_TCP_CONG" = "cubic";
              "DEVPORT" = "y";
              "DOUBLEFAULT" = "y";
              "DTC" = "y";
              "EARLY_PRINTK" = "y";
              "ETHERNET_PACKET_MANGLE" = "y";
              "EXTRA_FIRMWARE" = "";
              "EXTRA_TARGETS" = "";
              "FB_NOTIFY" = "y";
              "FIXED_PHY" = "y";
              "FLATMEM_MANUAL" = "y";
              "GACT_PROB" = "y";
              "GPIO_74X164" = "y";
              "GPIO_ATH79" = "y";
              "GPIO_GENERIC" = "y";
              "GPIOLIB_IRQCHIP" = "y";
              "GPIOLIB" = "y";
              "GPIO_NXP_74HC153" = "y";
              "GPIO_PCF857X" = "y";
              "GPIO_SYSFS" = "y";
              "HARDWARE_WATCHPOINTS" = "y";
              "HAVE_ARCH_MMAP_RND_BITS" = "y";
              "HAVE_ARCH_WITHIN_STACK_FRAMES" = "y";
              "HAVE_CLK_PREPARE" = "y";
              "HAVE_CLK" = "y";
              "HAVE_GCC_PLUGINS" = "y";
              "HAVE_KERNEL_BZIP2" = "y";
              "HAVE_KERNEL_CAT" = "y";
              "HAVE_KERNEL_GZIP" = "y";
              "HAVE_KERNEL_LZ4" = "y";
              "HAVE_KERNEL_LZMA" = "y";
              "HAVE_KERNEL_LZO" = "y";
              "HAVE_KERNEL_XZ" = "y";
              "HAVE_KVM" = "y";
              "HPET_MMAP_DEFAULT" = "y";
              "HW_HAS_PCI" = "y";
              "HW_PERF_EVENTS" = "y";
              "I2C_ALGOBIT" = "y";
              "I2C_BOARDINFO" = "y";
              "I2C_GPIO" = "y";
              "I2C" = "y";
              "IIO_CONSUMERS_PER_TRIGGER" = "2";
              "IMAGE_CMDLINE_HACK" = "y";
              "INITRAMFS_ROOT_GID" = "0";
              "INITRAMFS_ROOT_UID" = "0";
              "INITRAMFS_SOURCE" = "../../root";
              "IO_STRICT_DEVMEM" = "y";
              "IP17XX_PHY" = "y";
              "IPW2100_MONITOR" = "y";
              "IPW2200_MONITOR" = "y";
              "IRQCHIP" = "y";
              "KALLSYMS_BASE_RELATIVE" = "y";
              "KERNEL_MODE_NEON" = "y";
              "KERNEL_XZ" = "y";
              "KUSER_HELPERS" = "y";
              "LEDS_GPIO" = "y";
              "LIBFDT" = "y";
              "LOCALVERSION" = "";
              "LOCKD_V4" = "y";
              "LOG_CPU_MAX_BUF_SHIFT" = "12";
              "MAGIC_SYSRQ_DEFAULT_ENABLE" = "0x1";
              "MARVELL_PHY" = "y";
              "MDIO_BITBANG" = "y";
              "MDIO_BOARDINFO" = "y";
              "MDIO_GPIO" = "y";
              "MICREL_PHY" = "y";
              "MII" = "y";
              "MIPS_L1_CACHE_SHIFT" = "5";
              "MIPS_MACHINE" = "y";
              "MIPS_NO_APPENDED_DTB" = "y";
              "MIPS_SPRAM" = "y";
              "MMC_BLOCK_BOUNCE" = "y";
              "MMC_BLOCK_MINORS" = "8";
#              "MODULE_STRIPPED" = "y";
              "MTD_CFI_ADV_OPTIONS" = "y";
              "MTD_CFI_GEOMETRY" = "y";
              "MTD_CFI_NOSWAP" = "y";
              "MTD_CMDLINE_PARTS" = "y";
              "MTD_CYBERTAN_PARTS" = "y";
              "MTD_M25P80" = "y";
              "MTD_MYLOADER_PARTS" = "y";
              "MTD_NAND_DENALI_SCRATCH_REG_ADDR" = "0xff108018";
              "MTD_NAND_IDS" = "y";
              "MTD_OF_PARTS" = "y";
              "MTD_PHYSMAP_OF" = "y";
              "MTD_PHYSMAP" = "y";
              "MTD_REDBOOT_DIRECTORY_BLOCK" = "-2";
              "MTD_REDBOOT_PARTS" = "y";
              "MTD_SPI_NOR_USE_4K_SECTORS_LIMIT" = "4096";
              "MTD_SPI_NOR" = "y";
              "MTD_SPLIT_EVA_FW" = "y";
              "MTD_SPLIT_FIRMWARE_NAME" = "firmware";
              "MTD_SPLIT_LZMA_FW" = "y";
              "MTD_SPLIT_MINOR_FW" = "y";
              "MTD_SPLIT_SEAMA_FW" = "y";
              "MTD_SPLIT_TPLINK_FW" = "y";
              "MTD_SPLIT_UIMAGE_FW" = "y";
              "MTD_SPLIT_WRGG_FW" = "y";
              "MTD_TPLINK_PARTS" = "y";
              "MYLOADER" = "y";
              "NET_CLS_IND" = "y";
              "NET_CLS" = "y";
              "NET_DSA_MV88E6060" = "y";
              "NET_DSA_MV88E6063" = "y";
              "NET_DSA_TAG_TRAILER" = "y";
              "NET_DSA" = "y";
              "NET_EMATCH_STACK" = "32";
              "NET_IPGRE_BROADCAST" = "y";
              "NET_SWITCHDEV" = "y";
              "NET_VENDOR_3COM" = "y";
              "NET_VENDOR_ADAPTEC" = "y";
              "NET_VENDOR_AGERE" = "y";
              "NET_VENDOR_ALTEON" = "y";
              "NET_VENDOR_AMD" = "y";
              "NET_VENDOR_ATHEROS" = "y";
              "NET_VENDOR_BROCADE" = "y";
              "NET_VENDOR_CAVIUM" = "y";
              "NET_VENDOR_CHELSIO" = "y";
              "NET_VENDOR_CIRRUS" = "y";
              "NET_VENDOR_CISCO" = "y";
              "NET_VENDOR_DEC" = "y";
              "NET_VENDOR_DLINK" = "y";
              "NET_VENDOR_EMULEX" = "y";
              "NET_VENDOR_EXAR" = "y";
              "NET_VENDOR_FARADAY" = "y";
              "NET_VENDOR_FREESCALE" = "y";
              "NET_VENDOR_FUJITSU" = "y";
              "NET_VENDOR_HISILICON" = "y";
              "NET_VENDOR_HP" = "y";
              "NET_VENDOR_IBM" = "y";
              "NET_VENDOR_MELLANOX" = "y";
              "NET_VENDOR_MICROCHIP" = "y";
              "NET_VENDOR_MYRI" = "y";
              "NET_VENDOR_NVIDIA" = "y";
              "NET_VENDOR_OKI" = "y";
              "NET_VENDOR_QLOGIC" = "y";
              "NET_VENDOR_RDC" = "y";
              "NET_VENDOR_REALTEK" = "y";
              "NET_VENDOR_SILAN" = "y";
              "NET_VENDOR_SIS" = "y";
              "NET_VENDOR_SUN" = "y";
              "NET_VENDOR_TEHUTI" = "y";
              "NET_VENDOR_TI" = "y";
              "NET_VENDOR_TOSHIBA" = "y";
              "NET_VENDOR_XIRCOM" = "y";
              "NF_CONNTRACK_PROCFS" = "y";
              "NFS_COMMON" = "y";
              "NFSD_V3" = "y";
              "NFS_V3" = "y";
              "NLS_DEFAULT" = "iso8859-1";
              "OF_ADDRESS_PCI" = "y";
              "OF_ADDRESS" = "y";
              "OF_EARLY_FLATTREE" = "y";
              "OF_FLATTREE" = "y";
              "OF_GPIO" = "y";
              "OF_IRQ" = "y";
              "OF_MDIO" = "y";
              "OF_NET" = "y";
              "OF_PCI_IRQ" = "y";
              "OF_PCI" = "y";
              "OF" = "y";
              "PCI_AR724X" = "y";
              "PCI_DISABLE_COMMON_QUIRKS" = "y";
              "PCI_DOMAINS" = "y";
              "PCI_QUIRKS" = "y";
              "PCI_SYSCALL" = "y";
              "PCI" = "y";
              "PHYLIB" = "y";
              "PINCONF" = "y";
              "PINCTRL_SINGLE" = "y";
              "PINMUX" = "y";
              "PRINT_STACK_DEPTH" = "64";
              "PWRSEQ_EMMC" = "y";
              "PWRSEQ_SIMPLE" = "y";
              "RATIONAL" = "y";
              "RCU_CPU_STALL_TIMEOUT" = "60";
              "RCU_FANOUT" = "32";
              "RCU_FANOUT_LEAF" = "16";
              "RCU_TORTURE_TEST_SLOW_INIT_DELAY" = "3";
              "RTC_DRV_CMOS" = "y";
              "RTC_HCTOSYS_DEVICE" = "rtc0";
              "RTC_HCTOSYS" = "y";
              "RTC_INTF_DEV" = "y";
              "RTC_INTF_PROC" = "y";
              "RTC_INTF_SYSFS" = "y";
              "RTC_SYSTOHC_DEVICE" = "rtc0";
              "RTC_SYSTOHC" = "y";
              "RTL8306_PHY" = "y";
              "RTL8366RB_PHY" = "y";
              "RTL8366_SMI" = "y";
              "RTL8366S_PHY" = "y";
              "RTL8367_PHY" = "y";
              "RXKAD" = "y";
              "SCSI_DMA" = "y";
              "SCSI_LOWLEVEL" = "y";
              "SCSI_PROC_FS" = "y";
              "SELECT_MEMORY_MODEL" = "y";
              "SERIAL_8250_DMA" = "y";
              "SERIAL_8250_NR_UARTS" = "1";
              "SERIAL_8250_RUNTIME_UARTS" = "1";
              "SERIAL_AR933X_CONSOLE" = "y";
              "SERIAL_AR933X_NR_UARTS" = "2";
              "SERIAL_AR933X" = "y";
              "SLABINFO" = "y";
              "SLUB_CPU_PARTIAL" = "y";
              "SOC_AR933X" = "y";
              "SOC_AR934X" = "y";
              "SPI_ATH79" = "y";
              "SPI_BITBANG" = "y";
              "SPI_GPIO" = "y";
              "SPI_MASTER" = "y";
              "SPI" = "y";
              "STDBINUTILS" = "y";
              "SWCONFIG_LEDS" = "y";
              "SWCONFIG" = "y";
              "SWPHY" = "y";
              "SYS_HAS_CPU_MIPS32_R2" = "y";
              "SYS_HAS_EARLY_PRINTK" = "y";
              "SYS_SUPPORTS_MIPS16" = "y";
              "SYS_SUPPORTS_ZBOOT_UART_PROM" = "y";
              "SYS_SUPPORTS_ZBOOT" = "y";
              "SYSTEM_TRUSTED_KEYS" = "";
              "UDF_NLS" = "y";
              "UEVENT_HELPER_PATH" = "/sbin/hotplug";
              "UID16" = "y";
              "USE_OF" = "y";
              "VMSPLIT_3G" = "y";
              "WILINK_PLATFORM_DATA" = "y";
              "WLAN_80211" = "y";
              "WL_TI" = "y";
              "ZONE_DMA" = "y";
            };
          };
        };
  malta = { name = "qemu-malta"; endian = "big";
            kernel = lib: {
              defaultConfig = "malta/config-4.9";
              extraConfig = { "BLK_DEV_SR" = "y"; "E1000" = "y"; "PCI" = "y"; "NET_VENDOR_INTEL" = "y";};
            };
          };
}
