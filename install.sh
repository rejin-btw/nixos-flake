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

echo -e "${BLUE}=== NixOS 'Forever' Bootstrap (Clean Method) ===${NC}"

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
    # We always write to 'hosts/bootstrap' because that is what flake.nix expects!
    BOOTSTRAP_DIR="$FLAKE_PATH/hosts/bootstrap"
    
    # Ensure the directory exists (it should from the clone, but just in case)
    mkdir -p "$BOOTSTRAP_DIR"
    
    echo "Generating Hardware Config..."
    nixos-generate-config --root "$MOUNT_POINT"
    
    # Overwrite the bootstrap files with this machine's real hardware config
    mv "$MOUNT_POINT/etc/nixos/hardware-configuration.nix" "$BOOTSTRAP_DIR/"
    
    # Copy your template config to bootstrap/default.nix
    cp "$FLAKE_PATH/hosts/default.nix" "$BOOTSTRAP_DIR/default.nix"

    # 3. Handle Hostname (Optional, but good for reference)
    if [ -n "$1" ]; then
        NEW_HOSTNAME="$1"
    else
        read -p "Enter intended hostname (for reference): " NEW_HOSTNAME
    fi
    
    # We update the file, but we install as 'bootstrap' for now.
    # You can rename it properly after the first boot!
    sed -i "s/networking.hostName = .*/networking.hostName = \"$NEW_HOSTNAME\";/" "$BOOTSTRAP_DIR/default.nix"

    # 4. Permission Fix & Git Registration
    chown -R 1000:100 "$FLAKE_PATH"
    
    echo "Registering files with Git..."
    cd "$FLAKE_PATH"
    # Essential: Flakes ignore files not in git staging
    git add .

    # 5. Install using the Universal 'bootstrap' entry
    echo "Installing NixOS..."
    nixos-install --flake "$FLAKE_PATH#bootstrap"

    echo -e "${GREEN}System Installed!${NC}"
    echo -e "${BLUE}NOTE: When you log in, your hostname will be 'bootstrap'.${NC}"
    echo -e "You can rename the folder from 'hosts/bootstrap' to 'hosts/$NEW_HOSTNAME'"
    echo -e "and update flake.nix manually later. This is the safest way."
    exit 0
fi

# --- CHECK 2: Are we the User (Post-Reboot)? ---
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${GREEN}Detected User Mode. Starting DOTFILES Install...${NC}"
    
    cd ~
    if [ ! -d "dotfiles" ]; then
        echo "Cloning Dotfiles..."
        git clone $DOTFILES_REPO ~/dotfiles
    fi

    echo "Applying Home Manager..."
    # Dynamic version fetch
    nix run nixpkgs#home-manager -- switch --flake ~/nixos-flake#$TARGET_USER

    echo -e "${GREEN}Setup Complete! Welcome home.${NC}"
    exit 0
fi
