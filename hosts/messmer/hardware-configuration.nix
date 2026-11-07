{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/mapper/luks-42da2a05-d6a0-45ee-baea-d845e08cb578";
    fsType = "btrfs";
  };

  boot.initrd.luks.devices."luks-42da2a05-d6a0-45ee-baea-d845e08cb578".device =
    "/dev/disk/by-uuid/42da2a05-d6a0-45ee-baea-d845e08cb578";

  fileSystems."/home" = {
    device = "/dev/mapper/luks-42da2a05-d6a0-45ee-baea-d845e08cb578";
    fsType = "btrfs";
    options = [ "subvol=home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/mapper/luks-42da2a05-d6a0-45ee-baea-d845e08cb578";
    fsType = "btrfs";
    options = [ "subvol=nix" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BE5D-45B1";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
