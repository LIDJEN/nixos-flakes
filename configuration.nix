{ config, pkgs, lib, nixpkgs-stable, ... }:

let
  stable = nixpkgs-stable.legacyPackages.${pkgs.system};
in 
{
  # 🔧 IMPORT HARDWARE CONFIG (contains fileSystems, LUKS, swap)
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "rog-flow-x13";
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # 🔐 BOOT LOADER (TEMPORARILY DISABLE LANZABOOTE)
  # boot.initrd.systemd.enable = true;
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.efi.efiSysMountPoint = "/boot";
  boot.lanzaboote = { enable = true; pkiBundle = "/etc/secureboot"; };

  # 🎮 NVIDIA HYBRID GRAPHICS
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    offload = { enable = true; enableOffloadCmd = true; };
    intelBusId = "PCI:5:0:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  hardware.graphics = { enable = true; enable32Bit = true; };
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # ⌨️ KEYBOARD
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us,ru";
      variant = "colemak,";
      options = "grp:win_space_toggle,grp_led:scroll,compose:ralt";
    };
  };
  console.useXkbConfig = true;

  # 🖥️ DISPLAY
  services.displayManager.gdm = { enable = true; wayland = true; };
  services.desktopManager.gnome.enable = true;
  programs.niri.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk ];
  };

  security.polkit.enable =true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.swaylock = {};

  # 👆 FINGERPRINT
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-goodix;
  };
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services."gdm-password".fprintAuth = true;

  modules.niri.enable = true;
  modules.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      gopls
      texlab
    ];
  };

  # 📦 PACKAGES
  environment.systemPackages = with pkgs; [
    waybar wofi kitty grim slurp wl-clipboard swaynotificationcenter
    neovim git curl wget ripgrep fd bat
    nettools openvpn wireguard-tools tree
    vmware-workstation remmina freerdp virt-manager libvirt
    vivaldi thunderbird htop btop lsof pciutils usbutils lm_sensors
    asusctl supergfxctl btrfs-progs
  ];
  nixpkgs.config.allowUnfree = true;

  # 👤 USER
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];

  users.users.lidjen = {
    isNormalUser = true;
    description = "LIDJEN";
    extraGroups = [ "networkmanager" "wheel" "video" "libvirtd" "input" ];
    initialPassword = "123456789";
    packages = with pkgs; [ firefox ];
    shell = pkgs.zsh;
  };
  security.sudo.wheelNeedsPassword = true;

  # Fonts
  fonts.packages = with stable; [
    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono"]; })
  ];

  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono"];
    };
  };


  # GARBAGE
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # 🔧 HARDWARE
  hardware.sensor.iio.enable = true;
  services.power-profiles-daemon.enable = true;
  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true; alsa.enable = true; pulse.enable = true;
    jack.enable = true; wireplumber.enable = true;
  };

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
  };

  # Virtualisation
  virtualisation.vmware.host.enable = true;

  nix.settings.auto-optimise-store = true;
  system.stateVersion = "24.11";
}
