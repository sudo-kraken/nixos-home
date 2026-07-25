{
  inputs,
  pkgs,
  config,
  lib,
  username,
  ...
}:
let
  wslEnabled = if config ? wsl then config.wsl.enable else false;

  allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
      "vscode-extension-ms-vscode-remote-remote-ssh"
      "vscode-extension-ms-vscode-remote-remote-containers"
      "vscode-extension-MS-python-vscode-pylance"
      "discord"
      "spotify"
      "slack"
      "zoom-us"
      "zoom"
      "stremio-linux-shell"
      "packer"
    ];

  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfreePredicate = allowUnfreePredicate;
      # Joplin and Proton Mail have not yet moved off Electron 39. Keep this
      # exact so a lock update cannot silently permit a different EOL version.
      permittedInsecurePackages = [ "electron-39.8.10" ];
    };
  };
in
{
  imports = [
    inputs.home-manager-stable.nixosModules.home-manager
  ];

  options.myUser = {
    battery.enable = lib.mkOption {
      type = with lib.types; bool;
      default = false;
      description = "Enable battery configurations.";
    };
  };

  config = {
    # trippy does not support native unprivileged mode https://github.com/fujiapple852/trippy/issues/741
    security.wrappers.trip = {
      owner = "root";
      group = username;
      permissions = "u+rx,g+rx,o-rwx";
      capabilities = "cap_net_raw+p";
      source = "${pkgs-unstable.trippy}/bin/trip";
    };

    home-manager = {
      backupFileExtension = "backup";
      useGlobalPkgs = true;
      useUserPackages = true;

      extraSpecialArgs = {
        inherit
          inputs
          pkgs-unstable
          username
          wslEnabled
          ;
        guiEnabled = !wslEnabled;
        batteryEnabled = config.myUser.battery.enable;
        nvidiaEnabled = lib.elem "nvidia" config.services.xserver.videoDrivers;
      };

      users.${username} = {
        imports = [
          ./user
        ];

        home = {
          username = "${username}";
          homeDirectory = "/home/${username}";
        };

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        home.stateVersion = "24.05";
      };
    };
  };
}
