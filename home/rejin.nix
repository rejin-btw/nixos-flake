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
      export PATH="${lib.makeBinPath [ pkgs.pulseaudio pkgs.gnugrep pkgs.gawk pkgs.coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/toggle-audio.sh"}
    '')

    (writeShellScriptBin "vcp-control" ''
      export PATH="${lib.makeBinPath [ ddcutil coreutils ]}:$$PATH"
      ${builtins.readFile "${scriptsDir}/scripts/vcp_full_control.sh"}
    '')

    (pkgs.writeScriptBin "niri-mouse-scroll" ''
      #!${pkgs.python3.withPackages (ps: [ ps.evdev ])}/bin/python3
      ${builtins.readFile "${scriptsDir}/scripts/niri-mouse-scroll.py"}
    '')

    (writeSihellScriptBin "start-niri" ''
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
i    userEmail = "rejinks@zohomail.in";
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
   ".config/zathura".source = "${dotfilesPath}/../.config/zathura";
   ".config/lf".source = "${dotfilesPath}/../.config/lf";
   ".config/alacritty".source= "${dotfilesPath}/../.config/alacritty";
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


  

   
  
   home.sessionVariables = {
     EDITOR = "vim";
   };
}



