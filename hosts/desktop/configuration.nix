{ username, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ../../system
    ../../home
  ];

  boot.supportedFilesystems = [ "btrfs" ];

  mySystem = {
    game.enable = true;
    nvidia.enable = true;
    };
  };

  home-manager.users.${username} = {
    wayland.windowManager.hyprland.settings = {
      monitor = [
        "DP-1,3840x2160@120.00Hz,0x0,1"
        ",preferred,auto,auto"
      ];
      workspace = [
        "1,monitor:DP-1"
        "2,monitor:DP-1"
        "3,monitor:DP-1"
        "4,monitor:DP-1"
        "5,monitor:DP-1"
        "6,monitor:DP-1"
        "7,monitor:DP-1"
        "8,monitor:DP-1"
        "9,monitor:DP-1"
        "10,monitor:DP-1"
      ];
    };
  };
}
