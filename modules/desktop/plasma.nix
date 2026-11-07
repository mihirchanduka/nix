{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.plasma-login-manager.enable = true;
  systemd.services.plasmalogin.environment.XDG_DATA_DIRS =
    lib.mkForce "${config.services.displayManager.sessionData.desktops}/share:/run/current-system/sw/share";

  systemd.user.units."kde-baloo.service" = {
    overrideStrategy = "asDropin";
    text = ''
      [Unit]
      After=plasma-core.target
    '';
  };

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    khelpcenter
  ];

  environment.systemPackages =
    (with pkgs.kdePackages; [
      konsole
      ark
      gwenview
      filelight
    ])
    ++ (with pkgs; [
      _7zz
      ktailctl
    ]);

  programs.kdeconnect.enable = true;

  programs.partition-manager.enable = true;
}
