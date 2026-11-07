{ pkgs, username, ... }:
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb.layout = "us";
  console.useXkbConfig = true;
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnome-boxes
    gnome-software
    gnome-system-monitor
    gnome-logs
    dconf-editor
    file-roller
    baobab
    eog
    evince
    yelp
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.blur-my-shell

    adw-gtk3

    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
    geary
    gnome-music
  ];

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  users.users.${username}.extraGroups = [ "libvirtd" ];

  home-manager.users.${username}.dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "JetBrains Mono 11";
      gtk-theme = "adw-gtk3-dark";
    };
    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "caffeine@patapon.info"
        "blur-my-shell@aunetx"
        "gsconnect@andyholmes.github.io"
      ];
      favorite-apps = [
        "zen-beta.desktop"
        "org.equicord.equibop.desktop"
        "dev.zed.Zed.desktop"
        "org.gnome.Console.desktop"
        "com.stremio.Stremio.desktop"
        "org.gnome.Boxes.desktop"
        "spotify.desktop"
      ];
    };
  };
}
