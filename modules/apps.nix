{ inputs, pkgs, ... }:
{
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pyfinal: pyprev: {
          proton-vpn-api-core = pyprev.proton-vpn-api-core.overridePythonAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              substituteInPlace proton/vpn/backend/networkmanager/killswitch/wireguard/nmclient.py \
                --replace-fail "(NM.DeviceType.ETHERNET, NM.DeviceType.WIFI)" \
                  "(NM.DeviceType.ETHERNET, NM.DeviceType.WIFI, NM.DeviceType.VLAN)" \
                --replace-fail "NM.SETTING_WIRED_SETTING_NAME, NM.SETTING_WIRELESS_SETTING_NAME" \
                  "NM.SETTING_WIRED_SETTING_NAME, NM.SETTING_WIRELESS_SETTING_NAME, NM.SETTING_VLAN_SETTING_NAME"
            '';
          });
        })
      ];
    })
  ];

  environment.systemPackages = with pkgs; [
    proton-vpn
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium
    slack
    bitwarden-desktop

    vlc
    strawberry

    libreoffice
    drawio

    gimp
    darktable
    obsidian
    nicotine-plus
  ];
}
