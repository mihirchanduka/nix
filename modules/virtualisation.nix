{ username, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  users.users.${username}.extraGroups = [ "libvirtd" ];

  home-manager.users.${username}.dconf.settings."org/virt-manager/virt-manager/connections" = {
    autoconnect = [ "qemu:///system" ];
    uris = [ "qemu:///system" ];
  };
}
