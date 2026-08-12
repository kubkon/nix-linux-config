{
  description = "flake for ichimaru";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zed-nightly.url = "github:zed-industries/zed/nightly";
    tracy.url = "github:kubkon/tracy.nix";
    superluminal.url = "github:kubkon/superluminal-nix-linux";
    delta.url = "git+ssh://git@github.com/zed-industries/delta-nix-linux";
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, home-manager, zed-nightly, tracy, superluminal, delta, niri, stylix }: {
    nixosConfigurations."ichimaru" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit zed-nightly tracy superluminal delta;
      };

      modules = [
        ./configuration.nix
        ({ nixpkgs.overlays = [ niri.overlays.niri ]; })
        nixos-hardware.nixosModules.framework-amd-ai-300-series
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.kubkon = import ./modules/home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
          # home-manager.sharedModules = [ niri.nixosModules.niri ];
        }
        niri.nixosModules.niri
        {
          nixpkgs.overlays = [ niri.overlays.niri ];
        }
        stylix.nixosModules.stylix
      ];
    };
  };
}
