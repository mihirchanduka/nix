{
  config,
  pkgs,
  inputs,
  username,
  ...
}:
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    policies.ExtensionSettings = {
      "uBlock0@raymondhill.net" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
        installation_mode = "force_installed";
      };
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        installation_mode = "force_installed";
      };
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = false;
    extraConfig.PROJECTS = "${config.home.homeDirectory}/Projects";
  };

  home.packages = with pkgs; [
    spotify
    psst
    zed-editor
    lmstudio
    claude-code
    pi-coding-agent
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "nh os switch ~/nixos";
      update = "nh os boot --update ~/nixos";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "Mihir";
      email = "86383841+mihirchanduka@users.noreply.github.com";
    };
  };

  programs.gh.enable = true;

  programs.tmux.enable = true;
}
