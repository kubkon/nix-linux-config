{
  description = "flake for ichimaru";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager/master";
    zed-nightly.url = "github:zed-industries/zed";
    tracy.url = "github:kubkon/tracy.nix";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, zed-nightly, tracy }: {
    nixosConfigurations."ichimaru" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        inherit zed-nightly tracy;
      };

      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.framework-amd-ai-300-series
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.kubkon = import ./modules/home.nix;
        }
      ];
    };
  };
}
