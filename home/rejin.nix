{ config, pkgs, lib, dotfilesPath, ... }:

let
  scriptsDir = pkgs.runCommand "scripts" {
    src = "${dotfilesPath}";
  } ''
    mkdir -p $out
    cp -r $src $out
  '';
in
{
  home.username = "rejin";
  home.homeDirectory = "/home/rejin";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    vim
    wget
    alacritty
    fuzzel
    mako
    neovim
    wl-clipboard
    cliphist
    wl-clip-persist
    telegram-desktop
    phinger-cursors
    appflowy
    tree
    stow
    pavucontrol
    tmux
    python3
    inotify-tools
    krusader
    krename
    libsForQt5.kio-extras
    kdiff3
    lhasa
    zip
    unzip
    arj
    unar
    rpm
    p7zip
    freetube

    # Custom scripts
    (writeShellScriptBin "auto-consume" ''
      export PATH="${lib.makeBinPath [ libnotify jq procps niri coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/auto_consume.sh"}
    '')

    (writeShellScriptBin "datetime-notify" ''
      export PATH="${lib.makeBinPath [ libnotify coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/datetime_notify.sh"}
    '')

    (writeShellScriptBin "nvim-thunar" ''
      export PATH="${lib.makeBinPath [ neovim coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/nvim_thunar.sh"}
    '')

    (writeShellScriptBin "ram-monitor" ''
      export PATH="${lib.makeBinPath [ libnotify procps gawk coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/ram_monitor.sh"}
    '')

    (writeShellScriptBin "toggle-audio" ''
      export PATH="${lib.makeBinPath [ pulseaudio coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/toggle-audio.sh"}
    '')

    (writeShellScriptBin "vcp-control" ''
      export PATH="${lib.makeBinPath [ coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/vcp_full_control.sh"}
    '')

    (pkgs.writeScriptBin "niri-mouse-scroll" ''
      #!${pkgs.python3.withPackages (ps: [ ps.evdev ])}/bin/python3
      ${builtins.readFile "${scriptsDir}/scripts/niri-mouse-scroll.py"}
    '')

    (writeShellScriptBin "start-niri" ''
      export PATH="${lib.makeBinPath [ niri coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/start-niri.sh"}
    '')

    (pkgs.writeScriptBin "fuzzel-bookmarks" ''
      #!${pkgs.python3.withPackages (ps: [ ps.evdev ])}/bin/python3
      ${builtins.readFile "${scriptsDir}/scripts/firefox-bookmarks-fuzzel.py"}
    '')


    (writeShellScriptBin "watch-firefox-bookmarks" ''
      export PATH="${lib.makeBinPath [ inotify-tools python3 ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/bookmarks_watcher.sh"}
    '')
  ];

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

   home.file = {
   ".config/niri".source = "${dotfilesPath}/../.config/niri/nix";
   ".config/mako".source = "${dotfilesPath}/../.config/mako";
   ".config/fuzzel".source = "${dotfilesPath}/../.config/fuzzel";
   "scripts".source = "${dotfilesPath}";
 };

    xdg.portal = {
  enable = true;
  extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
  ];
  config = {
    common.default = "*";
  };
};

   
  
   home.sessionVariables = {
     EDITOR = "vim";
   };
}



