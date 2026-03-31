{
  config,
  lib,
  pkgs,
  ...
}:

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
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  # 3. HARDWARE
  hardware.i2c.enable = true;
  boot.kernelModules = [
    "i2c-dev"
    "v4l2loopback"
  ];

  #VIRTUAL CAMERA ACCESS FOR OBS
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  # 5. NETWORKING & TIME
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  time.timeZone = "Asia/Kolkata";
  networking.hostName = "thinkpad";

  # 6. SYSTEM PACKAGES
  environment.systemPackages = with pkgs; [
    efibootmgr
    os-prober
    ddcutil
    alsa-tools
    polkit_gnome
    home-manager
    brightnessctl
    batsignal
    libnotify

    (writeShellScriptBin "toggle-syncthing" ''
      if systemctl is-active --quiet syncthing.service; then
        sudo systemctl stop syncthing.service
        ${libnotify}/bin/notify-send "Syncthing" "Stopped - Saving Battery 🔋"
      else
        sudo systemctl start syncthing.service
        ${libnotify}/bin/notify-send "Syncthing" "Started Syncing 🔄"
      fi
    '')
  ];

  # 7. PROGRAMS
  programs.niri.enable = true;
  programs.fish.enable = true;
  programs.noisetorch.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.fstrim.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      # Your existing settings:
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # --- NEW AGGRESSIVE BATTERY TWEAKS ---

      # 1. CPU Energy Policy (Intel P-State)
      # Tells the Intel chip to prioritize energy efficiency over responsiveness
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      # 2. Disable CPU Turbo Boost on Battery
      # This is HUGE. It prevents the CPU from spiking to 3.4GHz just to open a webpage.
      CPU_BOOST_ON_BAT = 0;

      # 3. Wi-Fi Power Saving
      # Forces the Intel Wi-Fi card into a low-power sleep state when not actively downloading
      WIFI_PWR_ON_BAT = "on";

      # 4. PCIe ASPM (Active State Power Management)
      # Puts internal PCIe connections (NVMe drive, Wi-Fi card) into deep sleep when idle
      PCIE_ASPM_ON_BAT = "powersupersave";

      # 5. Audio Power Saving
      # Turns off the audio chip after 1 second of silence (instead of keeping it awake)
      SOUND_POWER_SAVE_ON_BAT = 1;
    };
  };

  services.udisks2.enable = true;
  #services.speechd.enable = true;
  services.flatpak.enable = true;
  services.displayManager.ly.enable = true;
  services.gvfs.enable = true;
  services.udev.packages = [
    pkgs.android-file-transfer
  ];
  # 1. Your Syncthing Setup
  services.syncthing = {
    enable = true;
    user = "rejin";
    dataDir = "/home/rejin/Documents";
    configDir = "/home/rejin/.config/syncthing";
  };

  # 2. Stop Syncthing from starting automatically at boot
  systemd.services.syncthing.wantedBy = lib.mkForce [ ];

  # 3. Allow your Niri keybind to start/stop it without a sudo password
  security.sudo.extraRules = [
    {
      users = [ "rejin" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl start syncthing.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl stop syncthing.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # 8. USERS
  users.users.rejin = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "i2c"
      "input"
      "video"
    ];
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
        sansSerif = [
          "Roboto"
          "Noto Sans Tamil"
        ];
        serif = [
          "Roboto Slab"
          "Noto Serif Tamil"
        ];
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
  virtualisation.waydroid.enable = true;

  # 13. FOR AUDIO-ENABLING PIPEWIRE
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  #15 adding zram
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50;

  #16 for notfications for 15 10 and 05
  systemd.user.services.batsignal = {
    description = "Battery monitor daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      # Systemd can be picky with the % symbol, so writing out "percent" is safest
      ExecStart = "${pkgs.batsignal}/bin/batsignal -w 15 -c 10 -d 5 -f 79 -D \"${pkgs.libnotify}/bin/notify-send 'Battery Danger' 'Battery is at 5 percent! Plug in now.' -u critical\"";
      Restart = "on-failure";
    };
  };

  # 16
  # Adjust TrackPoint sensitivity
  services.libinput = {
    enable = true;
    mouse = {
      accelProfile = "flat"; # Or "adaptive" for a more natural feel
      accelSpeed = "0.5"; # Range is -1.0 to 1.0. Increase for higher sensitivity.
    };
  };

  #17
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver # Replaces vaapiIntel
      libva-vdpau-driver # Replaces vaapiVdpau
      libvdpau-va-gl
    ];
  };

  #18 turning off muted state of audio and microphone on boot
  systemd.tmpfiles.rules = [
    # Turns off the F1 (Speaker Mute) LED
    "w /sys/class/leds/platform::mute/brightness - - - - 0"
    # Turns off the F4 (Mic Mute) LED
    "w /sys/class/leds/platform::micmute/brightness - - - - 0"
  ];

}
