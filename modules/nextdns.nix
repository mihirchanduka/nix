{ lib, ... }:
{
  services.nextdns = {
    enable = true;
    # Profile ID lives outside git (public repo). Create it once with:
    #   echo "profile <id>" | sudo tee /etc/nextdns/profile.conf
    # Flags below override anything in that file.
    arguments = [
      "-config-file"
      "/etc/nextdns/profile.conf"
      "-listen"
      "127.0.0.1:5300"
      "-report-client-info"
    ];
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [ "127.0.0.1:5300" ];
      Domains = [ "~." ];
      FallbackDNS = [ ];
    };
  };

  networking.networkmanager.dns = lib.mkForce "none";
}
