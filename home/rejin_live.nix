{ config, pkgs, lib, dotfilesPath, ... }:

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
  ];

in
{
  home.username = "rejin";
  home.homeDirectory = "/home/rejin";
  home.stateVersion = "25.05";

  # --- PACKAGES & WRAPPERS ---
  home.packages = with pkgs; [
    # GUI / CLI Tools
    vim wget fuzzel mako neovim wl-clipboard cliphist wl-clip-persist
    telegram-desktop phinger-cursors appflowy tree stow pavucontrol
    tmux python3 inotify-tools lhasa zip unzip arj unar rpm p7zip
    freetube zathura gnome-themes-extra adwaita-qt
    xfce.thunar xfce.thunar-volman xfce.thunar-media-tags-plugin xfce.thunar-archive-plugin
    lf fd fzf mpv localsend eza bat ripgrep alacritty starship zoxide

    # --- CUSTOM SCRIPTS (LIVE EDITING ENABLED) ---
    # These wrappers set up the dependencies ($PATH) but execute the file 
    # directly from your disk. Edit the file -> Run script -> Instant update.

    (writeShellScriptBin "auto-consume" ''
      export PATH="${lib.makeBinPath [ libnotify jq procps niri coreutils ]}:$PATH"
      exec ${localDotfiles}/scripts/auto_consume.sh "$@"
    '')

    (writeShellScriptBin "datetime-notify" ''
      export PATH="${lib.makeBinPath [ libnotify coreutils ]}:$PATH"
      exec ${localDotfiles}/scripts/datetime_notify.sh "$@"
    '')

    (writeShellScriptBin "nvim-thunar" ''
      export PATH="${lib.makeBinPath [ neovim coreutils ]}:$PATH"
      exec ${localDotfiles}/scripts/nvim_thunar.sh "$@"
    '')

    (writeShellScriptBin "ram-monitor" ''
      export PATH="${lib.makeBinPath [ libnotify procps gawk coreutils ]}:$PATH"
      exec ${localDotfiles}/scripts/ram_monitor.sh "$@"
    '')

    (writeShellScriptBin "toggle-audio" ''
      export PATH="${lib.makeBinPath [ pkgs.pulseaudio pkgs.gnugrep pkgs.gawk pkgs.coreutils ]}:$PATH"
      exec ${localDotfiles}/scripts/toggle-audio.sh "$@"
    '')

    (writeShellScriptBin "vcp-control" ''
      export PATH="${lib.makeBinPath [ ddcutil coreutils ]}:$PATH"
      exec ${localDotfiles}/scripts/vcp_full_control.sh "$@"
    '')

    (writeShellScriptBin "start-niri" ''
      export PATH="${lib.makeBinPath [ niri coreutils ]}:$PATH"
      exec ${localDotfiles}/scripts/start-niri.sh "$@"
    '')

    (writeShellScriptBin "watch-firefox-bookmarks" ''
      export PATH="${lib.makeBinPath [ inotify-tools python3 ]}:$PATH"
      exec ${localDotfiles}/scripts/bookmarks_watcher.sh "$@"
    '')

    # --- PYTHON SCRIPTS ---
    # We create a wrapper that includes the python env, then runs your local file.

    (writeShellScriptBin "niri-mouse-scroll" ''
      export PATH="${lib.makeBinPath [ (pkgs.python3.withPackages (ps: [ ps.evdev ])) ]}:$PATH"
      exec python3 ${localDotfiles}/scripts/niri-mouse-scroll.py "$@"
    '')

    (writeShellScriptBin "fuzzel-bookmarks" ''
      export PATH="${lib.makeBinPath [ (pkgs.python3.withPackages (ps: [ ps.evdev ])) ]}:$PATH"
      exec python3 ${localDotfiles}/scripts/firefox-bookmarks-fuzzel.py "$@"
    '')
  ];

  # --- GIT ---
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    userName = "rejin-btw";
    userEmail = "rejinks@zohomail.in";
    extraConfig = {
      credential.helper = "libsecret";
      core.editor = "vim";
    };
  };

  programs.firefox.enable = true;

  # --- CONFIG MANAGEMENT (THE FIX) ---
  
  # 1. Handle .config files
  xdg.configFile = 
    # Loop over the simple folders (recursive = false by default)
    (lib.genAttrs simpleConfigs (name: { source = mkLink name; })) 
    // 
    # Add special cases (Niri points to a subfolder)
    {
      "niri".source = mkLink "niri/nix";
    };

  # 2. Handle files in Home Root (Scripts folder)
  home.file = {
    "scripts".source = mkLinkHome "scripts";
  };

  # --- THEME & INTEGRATION ---
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  gtk = {
    enable = true;
    theme = { name = "Adwaita-dark"; package = pkgs.gnome-themes-extra; };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = { enable = true; style.name = "adwaita-dark"; };

  home.sessionVariables = { EDITOR = "vim"; };
}
