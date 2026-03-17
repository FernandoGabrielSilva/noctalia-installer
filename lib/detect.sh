detect_pkg() {
if command -v pacman &>/dev/null; then echo "pacman"
elif command -v apt &>/dev/null; then echo "apt"
else echo "unknown"
fi
}

detect_compositor() {
pgrep -x Hyprland &>/dev/null && echo "hyprland" && return
pgrep -x sway &>/dev/null && echo "sway" && return
pgrep -x niri &>/dev/null && echo "niri" && return
echo "unknown"
}
