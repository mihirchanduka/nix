{ ... }:
{
  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };

  boot.consoleLogLevel = 3;
  boot.kernelParams = [
    "quiet"
    "udev.log_level=3"
    "systemd.show_status=auto"
  ];
}
