{ config, lib, pkgs, ... }:

{
  # 1. IMPORTS (first)
  imports = [
    ./hardware-configuration.nix
  ];

  # 2. BOOT CONFIGURATION
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    extraConfig = ''
      source /boot/grub/custom.cfg
    '';
  };

  # 3. HARDWARE
  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-dev" ];

  # 4. ACTIVATION SCRIPTS
  system.activationScripts.appendArchEntry = {
    text = ''
      echo "Appending manual Arch entry to grub.cfg"
      cat <<EOF >> /boot/grub/grub.cfg

menuentry "Arch Linux" {
  insmod cryptodisk
  insmod luks
  insmod btrfs
  cryptomount UUID=7469c7d0-d62e-49a4-89b5-3bc9b05b0058
  set root='cryptouuid/7469c7d0-d62e-49a4-89b5-3bc9b05b0058'
  linux (hd0,gpt1)/vmlinuz-linux cryptdevice=UUID=7469c7d0-d62e-49a4-89b5-3bc9b05b0058:cryptroot root=/dev/mapper/cryptroot rw rootflags=subvol=@
  initrd (hd0,gpt1)/initramfs-linux.img
}
EOF
    '';
    deps = [ ];
  };

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

  services.udisks2.enable = true;

  

  # 8. USERS
  users.users.rejin = {
    isNormalUser = true;

    extraGroups = [ "wheel" "i2c" "input" ];
    packages = with pkgs; [ ];
  };

  # 9. FONTS
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [ roboto ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Roboto" ];
        serif = [ "Roboto Slab" ];
        monospace = [ "Roboto Mono" ];
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
  (pkgs.stdenv.mkDerivation {
    name = "hda-jack-retask-fw";
    # Relative path from hosts/default.nix to hardware/firmware is ../hardware/firmware
    src = ../hardware/firmware;
    installPhase = ''
      mkdir -p $out/lib/firmware
      cp hda-jack-retask.fw $out/lib/firmware/
    '';
  })
];
 
  



}


