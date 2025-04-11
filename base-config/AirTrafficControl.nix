{ outputs, inputs, lib, config, pkgs, modulesPath, ... }:{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8443 8080 8443 8880 6789 53 4000 3000 ];
    allowedUDPPorts = [ 3478 10001 1900 5514 53 ];

    #allowedUDPPortRanges = [
    #  { from = 4000; to = 4007; }
    #  { from = 8000; to = 8010; }
    #];
  };

# User stuff
  users = {
    mutableUsers = false;
    users = {
        tower = {
        isNormalUser = true;
        home = "/home/tower";
        description  = "tower user for ssh access";
        uid = 1000; 
        extraGroups = [ "wheel" "docker" "networkmanager" "storage" ]; 
        hashedPassword = "$y$j9T$ADqlLG8YEo2JYFKETFyhk.$WcfHEBV4mHYBULxujU4/VTUyNpcvVj7l0BLkmoEyY92"; 
        };
    };
  };

  services.tailscale.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";
  virtualisation.docker.liveRestore = false; # This breaks swarms

  system.stateVersion = "24.05";
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "be2iscsi" "hpsa" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}