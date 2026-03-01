{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "dm_crypt" "btrfs" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = {
    cryptroot = {
      device = "/dev/disk/by-uuid/01e50d38-22e0-4e38-8138-147bcbdd58da";
      preLVM = false;
    };
    cryptswap = {
      device = "/dev/disk/by-uuid/56b4f52a-7245-4fd3-827a-a7872bb622e1";
    };
  };


  # 💾 BTRFS WITH SUBVOLUMES
  fileSystems."/" = {
    device = "/dev/mapper/cryptroot";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5D4E-1766";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [ { device = "/dev/mapper/cryptswap"; } ];

  # boot.initrd.luks.devices."cryptroot".device = "...";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  system.stateVersion = "24.11";
}
