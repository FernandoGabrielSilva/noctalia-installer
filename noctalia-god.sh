#!/bin/bash

# ===== UI =====
clear
echo -e "${C}"
echo "███╗   ██╗ ██████╗  ██████╗████████╗ █████╗ ██╗      ██╗ █████╗ "
echo "████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██╔══██╗██║     ██║██╔══██╗"
echo "██╔██╗ ██║██║   ██║██║        ██║   ███████║██║     ██║███████║"
echo "██║╚██╗██║██║   ██║██║        ██║   ██╔══██║██║     ██║██╔══██║"
echo "██║ ╚████║╚██████╔╝╚██████╗    ██║   ██║  ██║███████╗██║██║  ██║"
echo "╚═╝ ╚═══╝ ╚═════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝"
echo -e "${N}"
echo -e "${G}Noctalia Installer GOD ULTRA${N}"
echo ""

set -e

echo "Baixando dependencias para o Noctalia Shell"

# ===============================
# PACOTES NECESSÁRIOS
# ===============================
sudo pacman -S --needed \
  noctalia-qs brightnessctl imagemagick python git \
  ddcutil power-profiles-daemon upower bluez \
  cliphist wlsunset xdg-desktop-portal python3 evolution-data-server
  
echo "Baixando o Noctalia Shell"

# ===============================
# Instalando Noctalia
# ===============================
paru -S noctalia-shell

echo "Autostart do Noctalia Shell"

# ===============================
# Autostart no Hiprlands
# ===============================
cat >> ~/.config/hypr/hyprland.conf <<EOF
exec-once = qs -c noctalia-shell
EOF

# ===== FINAL =====
echo ""
echo -e "${G}✔ Instalação concluída${N}"
echo "Reinicie sua sessão"
