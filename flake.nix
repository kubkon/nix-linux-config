{
  description = "flake for ichimaru";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/master";
    zed-nightly.url = "github:zed-industries/zed/nightly";
    tracy.url = "github:kubkon/tracy.nix";
    niri.url = "github:sodiboo/niri-flake";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, home-manager, zed-nightly, tracy, niri, stylix }: {
    nixosConfigurations."ichimaru" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit zed-nightly tracy;
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
