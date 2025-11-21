{ config, pkgs, lib, dotfilesPath, ... }:

let
  scriptsDir = pkgs.runCommand "scripts" {
    src = "${dotfilesPath}/scripts";
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

    (writeShellScriptBin "auto-consume" ''
      export PATH="${lib.makeBinPath [ libnotify jq procps niri coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/auto_consume.sh"}
    '')

    (writeShellScriptBin "datetime-notify" ''
      export PATH="${lib.makeBinPath [ libnotify coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/datetime_notify.sh"}
    '')

    (writeShellScriptBin "nvim-thunar" ''
      export PATH="${lib.makeBinPath [ neovim coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/nvim_thunar.sh"}
    '')

    (writeShellScriptBin "ram-monitor" ''
      export PATH="${lib.makeBinPath [ libnotify procps gawk coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/ram_monitor.sh"}
    '')

    (writeShellScriptBin "toggle-audio" ''
      export PATH="${lib.makeBinPath [ pulseaudio coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/toggle-audio.sh"}
    '')

    (writeShellScriptBin "vcp-control" ''
      export PATH="${lib.makeBinPath [ coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/vcp_full_control.sh"}
    '')

    (pkgs.writeScriptBin "niri-mouse-scroll" ''
      #!${pkgs.python3.withPackages (ps: [ ps.evdev ])}/bin/python3
      ${builtins.readFile "${scriptsDir}/niri-mouse-scroll.py"}
    '')

    (writeShellScriptBin "start-niri" ''
      export PATH="${lib.makeBinPath [ niri coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/start-niri.sh"}
    '')

    (writeShellScriptBin "fuzzel-bookmarks" ''
      export PATH="${lib.makeBinPath [ python3 sqlite ]}:$$PATH"
      python3 ${scriptsDir}/firefox_bookmarks_fuzzel.py
    '')

    (writeShellScriptBin "watch-firefox-bookmarks" ''
      export PATH="${lib.makeBinPath [ inotify-tools python3 ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/bookmarks_watcher.sh"}
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
    ".config/niri".source = "${dotfilesPath}/.config/niri/nix";
    ".config/mako".source = "${dotfilesPath}/.config/mako";
    ".config/fuzzel".source = "${dotfilesPath}/.config/fuzzel";
    "scripts".source = "${dotfilesPath}/scripts";
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };
}

