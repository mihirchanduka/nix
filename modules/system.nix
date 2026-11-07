{
  config,
  lib,
  pkgs,
  username,
  ...
}:
{
  boot.loader.limine = {
    enable = true;
    maxGenerations = 4;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = lib.mkDefault 50;
  };
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.optimise.automatic = true;

  programs.nh = {
    enable = true;
    flake = "/home/${username}/nixos";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 4";
    };
  };

  services.smartd = {
    enable = true;
    notifications.systembus-notify.enable = true;
  };

  services.btrfs.autoScrub = {
    enable = lib.any (fs: fs.fsType == "btrfs") (lib.attrValues config.fileSystems);
    interval = "monthly";
  };

  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;

  programs.nix-ld.enable = true;

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  time.timeZone = "America/Los_Angeles";
  i18n.defaultLocale = "en_US.UTF-8";

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    vim
    htop
    btop
    tree
    unzip
    ripgrep
    fastfetch
  ];
}
