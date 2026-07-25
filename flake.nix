{
  description = "Joe Harrison Nix configuration";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/2605.7.2";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    {
      self,
      systems,
      nixpkgs-stable,
      nixpkgs-unstable,
      treefmt-nix,
      ...
    }@inputs:
    let
      username = "joe";
      hostNames = [
        "desktop"
        "wsl"
      ];
      system = "x86_64-linux";

      eachSystem =
        f: nixpkgs-stable.lib.genAttrs (import systems) (system: f nixpkgs-stable.legacyPackages.${system});
      lib = nixpkgs-stable.lib;
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "ankama-launcher"
          "nvidia-x11"
          "nvidia-settings"
          "steam"
          "steam-original"
          "steam-run"
          "steam-unwrapped"
        ];
    in
    {
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);

      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });

      nixosConfigurations = lib.genAttrs hostNames (
        hostName:
        lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              hostName
              username
              inputs
              ;
            # Unstable packages with the same restricted unfree policy.
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfreePredicate = allowUnfreePredicate;
            };
          };
          modules = [
            ./hosts
            {
              nixpkgs.config = {
                # Restricted unfree policy for stable packages.
                allowUnfreePredicate = allowUnfreePredicate;
                # Heroic 2.20 is pinned to Electron 39 upstream.
                permittedInsecurePackages = [ "electron-39.8.10" ];
              };
            }
          ];
        }
      );
    };
}
