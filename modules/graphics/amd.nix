{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      libva-utils
    ];
  };

  environment.systemPackages = [ pkgs.nvtopPackages.amd ];
}
