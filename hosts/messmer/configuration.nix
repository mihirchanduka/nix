{
  hostname,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./sunshine.nix

    ../../modules
    ../../modules/desktop/plasma.nix
    ../../modules/graphics/nvidia.nix
    ../../modules/virtualisation.nix
  ];

  networking.hostName = hostname;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.blacklistedKernelModules = [ "acpi_tad" ];

  boot.loader.limine.efiInstallAsRemovable = true;

  boot.loader.limine.secureBoot = {
    enable = true;
    autoGenerateKeys = true;
  };
  environment.systemPackages = [ pkgs.sbctl ];

  boot.loader.limine.extraEntries = ''
    /Windows
        protocol: efi
        path: guid(b545adc7-8763-4262-a5b8-b2d72f60f793):/EFI/Microsoft/Boot/bootmgfw.efi
  '';

  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  boot.initrd.luks.devices."luks-42da2a05-d6a0-45ee-baea-d845e08cb578" = {
    allowDiscards = true;
    bypassWorkqueues = true;
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };

  fileSystems =
    lib.genAttrs [ "/" "/home" "/nix" ] (_: {
      options = [
        "compress=zstd"
        "noatime"
      ];
    })
    // {
      # "2TB HDD" (btrfs). Mounted here rather than udisks' /run/media so Chromium-based
      # browsers let websites save into it (Chromium blocks everything under /run).
      "/mnt/hdd" = {
        device = "/dev/disk/by-uuid/7cb1d554-8eae-43e8-a85e-e0486feea4e6";
        fsType = "btrfs";
        options = [
          "compress=zstd"
          "noatime"
          "nofail" # don't block boot if the drive is missing
          "x-systemd.automount" # mount on first access
        ];
      };
    };

  zramSwap.memoryPercent = 100;
  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 32 * 1024;
    }
  ];

  networking.networkmanager.settings.main.no-auto-default = "enp5s0";
  networking.networkmanager.ensureProfiles.profiles = {
    apartment-ethernet = {
      connection = {
        id = "Apartment Ethernet";
        uuid = "f50c569a-062d-3b82-bbbd-05fc084ae6ff";
        type = "ethernet";
        interface-name = "enp5s0";
      };
      ipv4.method = "disabled";
      ipv6.method = "disabled";
    };
    apartment-ethernet-vlan69 = {
      connection = {
        id = "Apartment Ethernet VLAN 69";
        uuid = "9a5b1ef5-8889-4903-bc5a-9f8594e9cd29";
        type = "vlan";
        interface-name = "enp5s0.69";
      };
      vlan = {
        parent = "enp5s0";
        id = 69;
        flags = 1;
      };
      ipv4 = {
        method = "auto";
        route-metric = 100;
      };
      ipv6.method = "disabled";
    };
  };

  system.stateVersion = "26.05";
}
