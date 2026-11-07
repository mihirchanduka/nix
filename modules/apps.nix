{ inputs, pkgs, ... }:
{
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

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
