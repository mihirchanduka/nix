{ hostname, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules
    ../../modules/disk.nix
    ../../modules/desktop/gnome.nix
    ../../modules/graphics/amd.nix
    ../../modules/framework.nix
  ];

  networking.hostName = hostname;

  disko.devices.disk.main.device = "/dev/nvme0n1";

  system.stateVersion = "25.11";
}
