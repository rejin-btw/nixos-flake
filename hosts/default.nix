{ config, lib, pkgs, ... }:

{
  # 1. IMPORTS (first)
  imports = [
    ./hardware-configuration.nix
  ];

  # 2. BOOT CONFIGURATION
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = false;
    extraEntries = ''
      menuentry "Linux Mint" {
        search --set=root --file /EFI/ubuntu/grubx64.efi
        chainloader /EFI/ubuntu/grubx64.efi
      }
    '';
    };
  # 3. HARDWARE
  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-dev" "v4l2loopback" ];

  #VIRTUAL CAMERA ACCESS FOR OBS
  boot.extraModulePackages = with config.boot.kernelPackages; [
  v4l2loopback
  ];


 
  # 5. NETWORKING & TIME
  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Kolkata";

  # 6. SYSTEM PACKAGES
  environment.systemPackages = with pkgs; [
    efibootmgr
    os-prober
    ddcutil
    alsa-tools
    polkit_gnome
    home-manager
  ];

  # 7. PROGRAMS
  programs.niri.enable = true;
  programs.fish.enable = true;
  programs.noisetorch.enable = true;

  services.udisks2.enable = true;
  services.flatpak.enable = true;
  services.displayManager.ly.enable = true;

  

  # 8. USERS
  users.users.rejin = {
    isNormalUser = true;

    extraGroups = [ "wheel" "i2c" "input" "video" ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];
  };

  # 9. FONTS
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [ 
      roboto               
      nerd-fonts.jetbrains-mono
      noto-fonts
      lohit-fonts.tamil
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Roboto" "Noto Sans Tamil" ];
        serif = [ "Roboto Slab" "Noto Serif Tamil" ];
        # Set JetBrains Mono as the default for terminals/code
        monospace = [ "JetBrainsMono Nerd Font" ]; 
      };
    };
  };


  # 11. STATE VERSION (LAST - at root level, not inside any block)
  system.stateVersion = "25.05";

  # 12. ENABLING SERVICES
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.polkit.enable = true;


  # 13. FOR AUDIO-ENABLING PIPEWIRE
    security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  #14. ADDING OVERIDE OF HDAJACKRETASK
hardware.firmware = [
    (pkgs.runCommand "hda-jack-retask-fw" { } ''
      mkdir -p $out/lib/firmware
      # We reference the file directly here
      cp ${../hardware/firmware/hda-jack-retask.fw} $out/lib/firmware/hda-jack-retask.fw
    '')
  ]; 
}


