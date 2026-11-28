{ pkgs, username, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [ "amd_pstate=active" ];

  hardware.enableRedistributableFirmware = true;

  services.power-profiles-daemon.enable = true;

  networking.networkmanager.wifi.powersave = true;

  services.fwupd.enable = true;

  services.fprintd.enable = true;

  environment.systemPackages = with pkgs; [
    powertop
    easyeffects
  ];

  home-manager.users.${username}.home.file = {
    ".local/share/easyeffects/output/kieran_levin.json".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/ceiphr/ee-framework-presets/27885fe00c97da7c441358c7ece7846722fd12fa/kieran_levin.json";
      hash = "sha256-a1JJ4L3Dse21cxev0EeQ83rVc5JU/HFlo1CZTGTSt/M=";
    };
    ".local/share/easyeffects/output/lappy_mctopface.json".source = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/ceiphr/ee-framework-presets/27885fe00c97da7c441358c7ece7846722fd12fa/lappy_mctopface.json";
      hash = "sha256-Z9jEIeQTkWAK0e9WZeI75umZeRE3WuaVnw6vAby1jf4=";
    };
  };
}
