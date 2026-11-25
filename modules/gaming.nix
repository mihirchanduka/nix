{ pkgs, username, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamescope.enable = true;
  programs.gamemode = {
    enable = true;
    settings.general.renice = 10;
  };
  users.users.${username}.extraGroups = [ "gamemode" ];

  boot.kernelModules = [ "ntsync" ];

  programs.gpu-screen-recorder = {
    ui.enable = true;
  };

  home-manager.users.${username}.xdg.autostart = {
    enable = true;
    entries = [
      "${
        pkgs.makeDesktopItem {
          name = "gpu-screen-recorder-ui";
          desktopName = "GPU Screen Recorder";
          icon = "gpu-screen-recorder";
          exec = "gsr-ui launch-daemon";
          noDisplay = true;
        }
      }/share/applications/gpu-screen-recorder-ui.desktop"
    ];
  };

  environment.systemPackages = with pkgs; [
    heroic
    (lutris.override {
      buildFHSEnv =
        args:
        buildFHSEnv (
          args
          // {
            multiPkgs = p: builtins.filter (x: (x.pname or "") != "gtk+") (args.multiPkgs p);
          }
        );
    })
    (hydralauncher.override {
      appimageTools = appimageTools // {
        wrapType2 =
          args:
          appimageTools.wrapType2 (
            args
            // {
              profile = ''
                export HYDRA_UMU_PYTHON=${pkgs.writeShellScript "hydra-umu-python" ''
                  if [ "$1" = -c ]; then exec ${pkgs.python3}/bin/python3 "$@"; fi
                  shift
                  exec ${pkgs.umu-launcher}/bin/umu-run "$@"
                ''}
              '';
            }
          );
      };
    })
    mangohud
    goverlay
    protontricks
    winetricks
    wineWow64Packages.stable
    umu-launcher
    (deadlock-mod-manager.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ aws-lc ];
    }))
  ];
}
