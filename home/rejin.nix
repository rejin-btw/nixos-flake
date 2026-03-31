{
  config,
  pkgs,
  lib,
  pkgs-unstable,
  ...
}:

let
  # --- CONFIGURATION ---
  # The absolute path to your git repo on disk
  localDotfiles = "/home/rejin/dotfiles";

  # --- HELPERS ---
  # Helper to link .config folders (e.g., ~/.config/mako -> ~/dotfiles/.config/mako)
  mkLink = path: config.lib.file.mkOutOfStoreSymlink "${localDotfiles}/.config/${path}";

  # Helper to link folders in Home Root (e.g., ~/scripts -> ~/dotfiles/scripts)
  mkLinkHome = path: config.lib.file.mkOutOfStoreSymlink "${localDotfiles}/${path}";

  # List of standard config folders to loop over
  simpleConfigs = [
    "mako"
    "fuzzel"
    "zathura"
    "lf"
    "alacritty"
    "nvim"
    "starship.toml"
    "fastfetch"
    "foot"
    "pistol"
  ];

in
{
  home.username = "rejin";
  home.homeDirectory = "/home/rejin";
  home.stateVersion = "25.05";

  # --- PACKAGES & WRAPPERS ---
  home.packages = with pkgs; [
    # GUI / CLI Tools
    vim
    wget
    fuzzel
    mako
    neovim
    wl-clipboard
    cliphist
    wl-clip-persist
    phinger-cursors
    tree
    stow
    pavucontrol
    tmux
    python3
    inotify-tools
    lhasa
    zip
    unzip
    arj
    unar
    rpm
    p7zip
    freetube
    zathura
    gnome-themes-extra
    adwaita-qt
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-media-tags-plugin
    xfce.thunar-archive-plugin
    lf
    fd
    fzf
    mpv
    localsend
    eza
    bat
    ripgrep
    alacritty
    starship
    zoxide
    gnome-disk-utility
    pkgs-unstable.appflowy
    rustc
    cargo
    gcc
    osu-lazer-bin
    chromium-bsu
    sgt-puzzles
    superTuxKart
    swaybg
    obs-studio
    alsa-utils
    xwayland-satellite
    fastfetch
    btop
    anki-bin
    imv
    ffmpegthumbnailer
    foot
    libsixel
    pistol
    chafa
    statix
    nil
    nixfmt-rfc-style
    imagemagick
    swww
    obs-cmd
    swaylock
    swayidle
    ungoogled-chromium
    libnotify
    obsidian
    foliate
    jq
    libmtp
    mtpfs
    usbutils
    gnome.gvfs
    ntfs3g
    exfatprogs
    quickemu
    virt-viewer
    pipe-viewer
    monophony
    wtype
    telegram-desktop
    super-productivity
    materialgram
    vlc
    pueue
    yt-dlp
    gammastep
    bibata-cursors
    # --- CUSTOM SCRIPTS (LIVE EDITING ENABLED) ---
    (writeShellScriptBin "auto-consume" ''
      export PATH="${
        lib.makeBinPath [
          libnotify
          jq
          procps
          niri
          coreutils
          python3
        ]
      }:$PATH"
      exec ${localDotfiles}/scripts/auto_consume.sh "$@"
    '')

    (writeShellScriptBin "datetime-notify" ''
      export PATH="${
        lib.makeBinPath [
          libnotify
          coreutils
        ]
      }:$PATH"
      exec ${localDotfiles}/scripts/datetime_notify.sh "$@"
    '')

    (writeShellScriptBin "toggle-audio" ''
      export PATH="${
        lib.makeBinPath [
          pkgs.pulseaudio
          pkgs.gnugrep
          pkgs.gawk
          pkgs.coreutils
        ]
      }:$PATH"
      exec ${localDotfiles}/scripts/toggle-audio.sh "$@"
    '')

    (writeShellScriptBin "vcp-control" ''
      export PATH="${
        lib.makeBinPath [
          ddcutil
          coreutils
        ]
      }:$PATH"
      exec ${localDotfiles}/scripts/vcp_full_control.sh "$@"
    '')

    (writeShellScriptBin "clean-system" ''
      export PATH="${
        lib.makeBinPath [
          coreutils
          nix
        ]
      }:$PATH"
      exec /home/rejin/dotfiles/scripts/clean-system.sh "$@"
    '')

    (writeShellScriptBin "update-wall" ''
      export PATH="${
        lib.makeBinPath [
          pkgs.imagemagick
          pkgs.swww
          pkgs.fontconfig
          pkgs.procps
          pkgs.coreutils
          pkgs.bash
        ]
      }:$PATH"
      exec ${localDotfiles}/scripts/update-wall.sh "$@"
    '')

    (writeShellScriptBin "niri-mouse-scroll" ''
      export PATH="${lib.makeBinPath [ (pkgs.python3.withPackages (ps: [ ps.evdev ])) ]}:$PATH"
      exec python3 ${localDotfiles}/scripts/niri-mouse-scroll.py "$@"
    '')
  ];

  # Auto-start the Polkit Authentication Agent
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # --- GIT ---
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    settings = {
      user = {
        name = "rejin-btw";
        email = "rejinks@zohomail.in";
      };
      credential.helper = "libsecret";
      core.editor = "vim";
    };
  };

  # OBSIDIAN BACKUP ON GIT
  systemd.user.services.obsidian-backup = {
    Unit = {
      Description = "Auto-backup Obsidian notes to GitHub";
      ConditionHost = "thinkpad";
    };
    Service = {
      Type = "oneshot";
      WorkingDirectory = "/home/rejin/ov-1";
      ExecStart = pkgs.writeShellScript "backup-obsidian" ''
        export PATH=$PATH:${pkgs.git}/bin:${pkgs.openssh}/bin
        git add .
        if ! git diff-index --quiet HEAD; then
           git commit -m "Auto-backup: $(date +'%Y-%m-%d %H:%M')"
           git push origin main
        fi
      '';
    };
  };

  systemd.user.timers.obsidian-backup = {
    Unit = {
      Description = "Trigger Obsidian backup every hour";
      ConditionHost = "thinkpad";
    };
    Timer = {
      OnBootSec = "15m";
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  programs.fish = {
    enable = true;
  };

  programs.firefox.enable = true;

  # --- CONFIG MANAGEMENT (THE FIX) ---

  # 1. Handle .config files
  xdg.configFile =
    (lib.genAttrs simpleConfigs (name: {
      source = mkLink name;
    }))
    // {
      "niri".source = mkLink "niri/nix";
      "fish/conf.d/rejin.fish".source = mkLink "fish/conf.d/rejin.fish";

    };

  # 2. Handle files in Home Root (Scripts folder)
  home.file = {
    "scripts".source = mkLinkHome "scripts";
  };

  # --- THEME & INTEGRATION ---
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = [ "gnome" ];
  };
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    style.name = "adwaita-dark";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  xdg.desktopEntries.super-productivity = {
    name = "Super Productivity";
    exec = "super-productivity --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
    terminal = false;
    categories = [ "Utility" ];
    icon = "super-productivity";
  };

  services.pueue.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";

  };

}
