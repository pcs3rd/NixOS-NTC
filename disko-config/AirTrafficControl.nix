{ inputs, outputs, lib, pkgs, modulesPath, ... }:{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.impermanence.nixosModules.impermanence
    inputs.disko.nixosModules.disko
    ];
  disko.devices = {
    disk = {
       system = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            esp = {
                priority = 1;
                name = "esp";
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
            };
            user = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                subvolumes = {
                  "/stateful" = {
                      mountOptions = [ "compress=zstd" "noexec" ];
                      mountpoint = "/stateful";
                  };
                  "/sys-data" = {
                      mountOptions = [ "compress=zstd" "noexec" ];
                      mountpoint = "/sys-data";
                  };
                  "/docker" = {
                      mountOptions = [ "compress=zstd" "noatime" ];
                      mountpoint = "/var/lib/docker";
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=1G"
        "defaults"
        "mode=755"
      ];
    };
    nodev."/home/tower" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=666"
        "noexec"
      ];
    };
  };
    boot.loader = {
        efi = {
            canTouchEfiVariables = true;
        };
        grub = {
            enable = true;
            efiSupport = true;
            version = 3;
        };
    };
    fileSystems."/sys-data".neededForBoot = true;
    fileSystems."/stateful".neededForBoot = true;

    environment.persistence."/sys-data" = {
        enable = true; 
        hideMounts = true;
        directories = [
            "/var/log"
            "/var/lib/nixos"
            "/var/lib/tailscale/"
            "/var/lib/systemd/coredump"
            "/etc/NetworkManager/system-connections"        
        ];
        files = [
        { file = "/etc/machine-id"; parentDirectory = { mode = "u=rwx,g=rwx,o=r"; }; }
        { file = "/etc/ssh/ssh_host_rsa_key"; parentDirectory = { mode = "u=rwx,g=r,o=r"; }; }
        { file = "/etc/ssh/ssh_host_rsa_key.pub"; parentDirectory = { mode = "u=rwx,g=r,o=r"; }; }
        { file = "/etc/ssh/ssh_host_ed25519_key"; parentDirectory = { mode = "u=rwx,g=r,o=r"; }; }
        { file = "/etc/ssh/ssh_host_ed25519_key.pub"; parentDirectory = { mode = "u=rwx,g=r,o=r"; }; }
        ];
    };
}
