{
  description = "nix-config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11-small";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    impermanence,
    disko, 
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "i686-linux"
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {

    nixosConfigurations = {
      AirTrafficControl = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
            ./base-config/AirTrafficControl.nix
            ./disko-config/AirTrafficControl.nix
            {
              networking.hostName = "AirTrafficControl";
              boot.loader.grub.device = "/dev/sdb";
              disko.devices.disk.system.device = "/dev/sdb";
            }
        ];
      };
    };
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      # FIXME replace with your username@hostname
      "tower@AirTrafficControl" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          # > Our main home-manager configuration file <
          ./home-config/tower.nix

        ];
      };
    };
  };
}
