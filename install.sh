#!/usr/bin/env bash

# --- CONFIGURATION ---
GITHUB_USER="rejin-btw"
FLAKE_REPO="https://github.com/$GITHUB_USER/nixos-flake.git"
DOTFILES_REPO="https://github.com/$GITHUB_USER/dotfiles.git"
TARGET_USER="rejin"
MOUNT_POINT="/mnt"
FLAKE_PATH="$MOUNT_POINT/home/$TARGET_USER/nixos-flake"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== NixOS 'Forever' Bootstrap Script ===${NC}"

# --- CHECK 1: Are we in the Live ISO (Root)? ---
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${GREEN}Detected Root/Live ISO. Starting SYSTEM Install...${NC}"

    if ! grep -qs "$MOUNT_POINT" /proc/mounts; then
       echo -e "${RED}Error: Drives not mounted to /mnt.${NC}"
       exit 1
    fi

    # 1. Clone System Repo
    echo "Cloning NixOS Flake..."
    mkdir -p "$MOUNT_POINT/home/$TARGET_USER"
    if [ ! -d "$FLAKE_PATH" ]; then
        nix-shell -p git --run "git clone $FLAKE_REPO $FLAKE_PATH"
    fi

    # 2. Hardware Logic
    echo "Generating Hardware Config..."
    read -p "Enter Hostname for this machine: " NEW_HOSTNAME
    HOST_DIR="$FLAKE_PATH/hosts/$NEW_HOSTNAME"
    mkdir -p "$HOST_DIR"
    
    nixos-generate-config --root "$MOUNT_POINT"
    mv "$MOUNT_POINT/etc/nixos/hardware-configuration.nix" "$HOST_DIR/"
    cp "$FLAKE_PATH/hosts/default.nix" "$HOST_DIR/default.nix"

    # 3. Update Hostname in file
    sed -i "s/networking.hostName = .*/networking.hostName = \"$NEW_HOSTNAME\";/" "$HOST_DIR/default.nix"

    # 4. Prompt for Edit
    echo -e "${BLUE}Action Required: Add '$NEW_HOSTNAME' to flake.nix inputs now.${NC}"
    read -p "Press Enter to open editor..."
    nano "$FLAKE_PATH/flake.nix"

    # 5. Permission Fix & Install
    chown -R 1000:100 "$FLAKE_PATH"
    echo "Installing NixOS..."
    nixos-install --flake "$FLAKE_PATH#$NEW_HOSTNAME"

    echo -e "${GREEN}System Installed! Reboot, log in as $TARGET_USER, and run this script again to finish.${NC}"
    exit 0
fi

# --- CHECK 2: Are we the User (Post-Reboot)? ---
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${GREEN}Detected User Mode. Starting DOTFILES Install...${NC}"
    
    cd ~
    
    # 1. Clone Dotfiles
    if [ ! -d "dotfiles" ]; then
        echo "Cloning Dotfiles..."
        git clone $DOTFILES_REPO ~/dotfiles
    fi

    # 2. Dynamic Home Manager Install
    echo "Applying Home Manager..."
    # This uses the 'home-manager' from the system's package set (nixpkgs)
    # ensuring it always matches your current OS version.
    nix run nixpkgs#home-manager -- switch --flake ~/nixos-flake#$TARGET_USER

    echo -e "${GREEN}Setup Complete! Welcome home.${NC}"
    exit 0
fi
