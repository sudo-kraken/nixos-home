{
  description = "Joe Harrison Nix configuration";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=2.93.3-2";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
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
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
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
            # pkgs-unstable avec la configuration unfree
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfreePredicate = allowUnfreePredicate;
            };
          };
          modules = [
            ./hosts
            # Configuration unfree pour nixpkgs stable
            { nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate; }
          ];
        }
      );
    };
}
