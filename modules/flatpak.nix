{ inputs, pkgs, ... }:
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    packages = [
      "org.equicord.equibop"
      "org.vinegarhq.Sober"
      "com.vysp3r.ProtonPlus"
      "com.usebottles.bottles"
      "com.stremio.Stremio"
    ];
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
