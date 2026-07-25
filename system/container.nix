{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.podman-compose ];

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
