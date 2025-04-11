{
  description = "nix-config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11-small";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = {
    self,
    nixpkgs,
    impermanence,
    disko, 
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
            {
              networking.hostName = "AirTrafficControl";
              boot.loader.grub.device = "/dev/sdb";
              disko.devices.disk.system.device = "/dev/sdb";
            }
        ];
      };
    };
  };
}
