install_deps() {
PKG=$1

if [ "$PKG" = "pacman" ]; then
sudo pacman -S --noconfirm git curl brightnessctl cava wl-clipboard
else
sudo apt install -y git curl brightnessctl cava wl-clipboard
fi
}
