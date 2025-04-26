#!/bin/bash
# Make an ascii art to welcome the user to the script
echo "###############################################################################################################"
echo "Welcome to the Garuda Sway Config installation script"
echo "This script will install all the dependencies required and copy the files from garuda-sway-config to ~/.config"
echo "Please make sure you have an active internet connection before running this script"
echo "Press Ctrl+C to exit the script"
echo "Press Enter to continue"
echo "###############################################################################################################"
read

# Get this script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Get distro name
distro=$(cat /etc/os-release | grep -w "NAME" | cut -d "=" -f2 | tr -d '"')

# Ask the user if they want to update the system
echo "It is recommended to update your system first. Do you want to update the system? (y/n)"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    # If the distro is Garuda Linux, update the system using update command, else use pacman
    echo "Updating system"
    if [ "$distro" == "Garuda Linux" ]; then
        echo "Detected Garuda Linux, updating system..."
        update
    else
        echo "Not Garuda Linux, updating system using dnf..."
        sudo dnf upgrade --refresh -y
        
    fi
else
    echo "Skipping system update..."
fi

# Function to check if a package is installed, if not, install it using dnf
function install {
    if ! dnf list installed $1 &> /dev/null; then
        echo "Installing $1..."
        sudo dnf install $1 -y
    else
        echo "$1 is already installed. Skipping..."
    fi
}

# Install dependencies using the install function
# Make an array of all the dependencies (swaylock-effects rofi-lbonn-wayland waybar-git neofetch cava foot hyprland-git mpd mpc sweet-cursor-theme-git ttf-font-awesome nerd-fonts hyprpicker pipewire wireplumber fish)
dependencies=(
    fastfetch
    cava-git
    foot
    mpd
    mpc
    ttf-font-awesome
    nerd-fonts
    hyprpicker
    pipewire
    wireplumber
    fish
    pavucontrol
    most
    rose-pine-cursor
    rose-pine-hyprcursor
    bluez
    bluez-utils
    grimblast
    gpu-screen-recorder
    btop
    networkmanager
    matugen
    wl-clipboard
    swww
    dart-sass
    brightnessctl
    gnome-bluetooth-3.0
    micro
    blueberry
    oh-my-posh
    wofi-emoji
    kitty
)

important_dependencies=(
    sway
    swayfx
    swaylock
    swaylock-effects
    waybar
    rofi-lbonn-wayland
)

# Highly probable that those packages are already installed, but just in case
conflicting_packages=(
    hyprland
    aylurs-gtk-shell
)

echo "Installing dependencies"
# Loop through the array and install all the dependencies
for i in "${dependencies[@]}"; do
    install $i
done

# curl -fsSL https://bun.sh/install | bash && \
# ln -s $HOME/.bun/bin/bun /usr/local/bin/bun

echo "Dependencies installed successfully"

echo "Uninstalling conflicting packages"
for i in "${conflicting_packages[@]}"; do
    # ask user if they want to uninstall the conflicting packages
    echo "Do you want to uninstall $i? (y/n)"
    read answer
    if [ "$answer" != "${answer#[Yy]}" ] ;then
        echo "Removing $i..."
        sudo dnf remove $i -y
    else
        echo "Skipping $i..."
    fi
done
echo "Conflicting packages uninstalled successfully"

echo "Installing important dependencies"
echo "You may be asked to replace some packages. Press y to replace them"
# Loop through the array and install all the dependencies
for i in "${important_dependencies[@]}"; do
    sudo dnf install $i -y
done
echo "Important Dependencies installed successfully"

# Uninstall wlsunset if installed (yes, i hate it)
echo "Uninstalling wlsunset"
if dnf list installed wlsunset &> /dev/null; then
    sudo dnf remove wlsunset -y
fi
echo "wlsunset uninstalled successfully"

# Place the files from garuda-sway-config (where this script is located) inside the .config folder
echo "Copying files from garuda-hyprdots to ~/.config"
# copy but ignore the .git folder, LICENSE, .gitignore and README.md
rsync -av $DIR/* ~/.config --exclude='.git' --exclude='LICENSE' --exclude='.gitignore' --exclude='README.md'
echo "Files copied successfully"

# Edit some config files
# Adding btop theme
echo "color_theme = $HOME/.config/btop/themes/catppuccin_macchiato.theme" >> $HOME/.config/btop/btop.conf

# Ask if the user wants to reboot the system now or not
echo "Do you want to reboot the system now? (y/n)"
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Installation completed successfully. Rebooting in 5 seconds..."
    # Wait for 5s before rebooting
    sleep 5
    sudo reboot now
else
    echo "Installation completed successfully. Please reboot your system to apply the changes."
fi

