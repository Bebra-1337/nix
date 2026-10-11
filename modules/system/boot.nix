{ pkgs, ... }:

let
  # Форк gitlab:lobstermane/evangelion-ui-plymouth: кадры масштабируются под экран
  evangelion-ui-plymouth = pkgs.stdenvNoCC.mkDerivation {
    pname = "evangelion-ui-plymouth";
    version = "1.1";
    src = ../../hosts/BEBRA-PC/themes/evangelion-ui;
    installPhase = ''
      dir=$out/share/plymouth/themes/evangelion-ui
      mkdir -p $dir
      cp evangelion-ui.script $dir/
      tar -xzf images.tar.gz -C $dir/
      substitute evangelion-ui.plymouth $dir/evangelion-ui.plymouth \
        --replace-fail "EVANGELION_UI_PATH" "$out"
    '';
  };
in
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
      themePackages = [ evangelion-ui-plymouth ];
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

  # NVMe отвалился 11.10 даже без ASPM: ядро отдаёт EIO, D-state нет → hung_task_panic молчит,
  # система часами живёт без корня, журнал (на том же NVMe) пуст. Поэтому:
  #  1) пишем /dev/kmsg на /mnt/storage (отдельный SATA HDD);
  #  2) если nvme0 не live или прямое чтение не проходит 30 с подряд → sysrq-c → pstore + ребут.
  # Всё крутится из статического busybox в /run (tmpfs), чтобы не нужен был ни один файл с NVMe.
  systemd.services.nvme-watchdog =
    let
      main = pkgs.writeText "nvme-watchdog.sh" ''
        export PATH=/run/nvme-watch/bin
        dir=/mnt/storage/kmsg
        log=
        if mkdir -p $dir; then
          log=$dir/$(date +%F_%H-%M-%S).log
          echo "# boot_id $(cat /proc/sys/kernel/random/boot_id), $(date '+%F %T %z'), uptime $(cut -d' ' -f1 /proc/uptime) s" >> $log
          ls -1t $dir/*.log | tail -n +61 | xargs -r rm -f
          # cat падает с EPIPE, если буфер kmsg переполнился, — просто переоткрываем
          ( while :; do cat /dev/kmsg >> $log; sleep 1; done ) &
        fi

        fails=0
        while :; do
          state=$(cat /sys/class/nvme/nvme0/state 2>/dev/null)
          if [ "$state" = live ] && dd if=/dev/nvme0n1 of=/dev/null bs=4096 count=1 iflag=direct 2>/dev/null; then
            fails=0
          else
            fails=$((fails + 1))
            echo "<2>nvme-watchdog: nvme0 state=''${state:-gone}, check failed ($fails/6)" > /dev/kmsg
            if [ $fails -ge 6 ]; then
              echo "<0>nvme-watchdog: NVMe lost, forcing panic for pstore" > /dev/kmsg
              [ -n "$log" ] && sync -f $log &
              sleep 3
              echo c > /proc/sysrq-trigger
            fi
          fi
          sleep 5
        done
      '';
      setup = pkgs.writeShellScript "nvme-watchdog-setup" ''
        d=/run/nvme-watch
        ${pkgs.coreutils}/bin/install -Dm755 ${pkgs.pkgsStatic.busybox}/bin/busybox $d/bin/busybox
        $d/bin/busybox --install -s $d/bin
        ${pkgs.coreutils}/bin/install -m644 ${main} $d/main.sh
      '';
    in
    {
      description = "Log kmsg to /mnt/storage and panic if NVMe drops out";
      wantedBy = [ "multi-user.target" ];
      wants = [ "mnt-storage.mount" ];
      after = [ "mnt-storage.mount" ];
      serviceConfig = {
        ExecStartPre = setup;
        ExecStart = "/run/nvme-watch/bin/busybox sh /run/nvme-watch/main.sh";
        RuntimeDirectory = "nvme-watch";
        Restart = "always";
        RestartSec = 5;
        OOMScoreAdjust = -1000;
      };
    };
}
