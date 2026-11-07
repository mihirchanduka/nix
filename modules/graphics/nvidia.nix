{
  config,
  pkgs,
  username,
  ...
}:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
  };

  boot.kernelParams = [ "plymouth.use-simpledrm" ];

  environment.systemPackages = [
    pkgs.nvtopPackages.nvidia
  ];

  nixpkgs.overlays = [
    (final: prev: {
      btop = final.symlinkJoin {
        inherit (prev.btop) name meta;
        paths = [ prev.btop ];
        nativeBuildInputs = [ final.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/btop --prefix LD_LIBRARY_PATH : ${final.addDriverRunpath.driverLink}/lib
        '';
      };
    })
  ];

  services.sunshine.package = pkgs.sunshine.override { cudaSupport = true; };

  hardware.nvidia-container-toolkit.enable = true;

  environment.sessionVariables = {
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };

  home-manager.users.${username}.programs.zen-browser.policies.Preferences = {
    "media.ffmpeg.vaapi.enabled" = {
      Value = true;
      Status = "default";
    };
    "widget.dmabuf.force-enabled" = {
      Value = true;
      Status = "default";
    };
  };
}
