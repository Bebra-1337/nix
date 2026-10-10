{ inputs, pkgs, ... }:

{
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    loader = {
      systemd-boot.enable = false;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        useOSProber = true;
        splashImage = null;
        theme = ../../hosts/BEBRA-PC/themes/CyberGRUB-2077;
      };
    };
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "systemd.show_status=false"
      "nvidia_drm.modeset=1"
      "nvidia_drm.fbdev=1"
      # NVMe (InnoGrit IG5236) отваливался с CSTS=0x1 → btrfs RO → kernel panic (02.08, 08.10)
      "nvme_core.default_ps_max_latency_us=0" # выключить APST
      "pcie_aspm=off" # ASPM на линке NVMe это НЕ выключает — см. pcie-disable-aspm ниже
      "panic=10" # при панике перезагружаться, а не висеть
      # "mitigations=off" # удалено: уязвимость к Spectre/Meltdown без ощутимого прироста на десктопе
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.cleanOnBoot = true;

    # Отвал NVMe не всегда даёт панику: система живёт без диска и ничего не пишет в журнал.
    # Превращаем это в панику → dmesg уходит в EFI pstore (/var/lib/systemd/pstore) → ребут через 10 с.
    kernel.sysctl = {
      "kernel.sysrq" = 1; # Alt+PrintScreen+C — ручная паника, если система ещё жива
      "kernel.hung_task_panic" = 1;
      "kernel.hung_task_timeout_secs" = 180;
      "kernel.softlockup_panic" = 1;
      "kernel.hardlockup_panic" = 1;
    };

    plymouth = {
      enable = true;
      theme = "evangelion-ui";
      themePackages = [
        inputs.evangelion-ui-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };

  # BIOS X99-D4 включает ASPM L1 на процессорных портах (NVMe, видеокарта), но через FADT
  # запрещает ОС управлять ASPM, поэтому pcie_aspm=off его не трогает (как и ASPM Global в BIOS —
  # он только про порты PCH). Выключаем вручную: сначала на всех функциях устройства, потом на порту.
  systemd.services.pcie-disable-aspm = {
    description = "Disable PCIe ASPM on NVMe and GPU links";
    wantedBy = [ "sysinit.target" "post-resume.target" ];
    after = [ "post-resume.target" ];
    before = [ "sysinit.target" ];
    unitConfig.DefaultDependencies = false;
    serviceConfig.Type = "oneshot";
    path = [ pkgs.pciutils pkgs.coreutils ];
    script = ''
      aspm_off() { setpci -s "$1" CAP_EXP+0x10.w=0x0000:0x0003 || echo "skip $1"; }
      for dev in /sys/bus/pci/devices/*; do
        # 0x010802 — NVMe, 0x03xxxx — видеокарты
        case "$(cat "$dev/class")" in 0x010802 | 0x03*) ;; *) continue ;; esac
        port=$(dirname "$(readlink -f "$dev")")
        case "$(basename "$port")" in pci*) continue ;; esac # встроено в root complex, линка нет
        for fn in "$port"/0000:*.[0-7]; do aspm_off "$(basename "$fn")"; done
        aspm_off "$(basename "$port")"
      done
    '';
  };
}
