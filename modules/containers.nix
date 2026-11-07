{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    distrobox
    kontainer
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
}
