#!/bin/bash

cd "$(dirname "$0")"
#!/bin/bash

LOG="$HOME/noctalia-god.log"
exec > >(tee -a "$LOG") 2>&1

R="\e[31m"; G="\e[32m"; Y="\e[33m"; C="\e[36m"; N="\e[0m"

# ===== UI =====
clear
echo -e "${C}"
echo "███╗   ██╗ ██████╗  ██████╗████████╗ █████╗ ██╗      ██╗ █████╗ "
echo "████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██╔══██╗██║     ██║██╔══██╗"
echo "██╔██╗ ██║██║   ██║██║        ██║   ███████║██║     ██║███████║"
echo "██║╚██╗██║██║   ██║██║        ██║   ██╔══██║██║     ██║██╔══██║"
echo "██║ ╚████║╚██████╔╝╚██████╗    ██║   ██║  ██║███████╗██║██║  ██║"
echo "╚═╝ ╚═══╝ ╚═════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝╚═ ╚═╝"
echo -e "${N}"
echo -e "${G}Noctalia Installer GOD${N}"
echo ""

ask() {
while true; do
read -p "$1 (y/n): " yn
case $yn in
[Yy]*) return 0 ;;
[Nn]*) return 1 ;;
*) echo "y/n" ;;
esac
done
}

fail(){ echo -e "${R}$1${N}"; exit 1; }
ok(){ echo -e "${G}✔ $1${N}"; }
step(){ echo -e "${Y}➜ $1${N}"; sleep 1; }

# ===== DETECTAR NOCTALIA =====
NOCTALIA_DIR="$HOME/.config/quickshell/noctalia-shell"

if [ -d "$NOCTALIA_DIR" ]; then
echo -e "${Y}Noctalia já está instalado!${N}"
echo "1) Continuar (reinstalar por cima)"
echo "2) Remover e instalar do zero"
echo "3) Cancelar instalação"
read -p "Escolha: " opt

case $opt in
1) ok "Continuando..." ;;
2)
    step "Removendo Noctalia"
    rm -rf ~/.config/quickshell/noctalia-shell
    rm -rf ~/.config/noctalia
    ok "Removido"
    ;;
3) exit 0 ;;
*) fail "Opção inválida" ;;
esac
fi

# ===== WAYLAND =====
[ "$XDG_SESSION_TYPE" != "wayland" ] && fail "Use Wayland"

# ===== PKG =====
if command -v pacman &>/dev/null; then PKG="pacman"
elif command -v apt &>/dev/null; then PKG="apt"
else fail "Distro não suportada"
fi

ok "PKG: $PKG"

# ===== COMPOSITOR =====
COMP=""
pgrep -x Hyprland &>/dev/null && COMP="hyprland"
pgrep -x sway &>/dev/null && COMP="sway"
pgrep -x niri &>/dev/null && COMP="niri"

if [ -z "$COMP" ]; then
echo "Escolha compositor:"
select c in hyprland sway niri; do COMP=$c; break; done
fi

ok "Compositor: $COMP"

# ===== BACKUP =====
if ask "Backup configs?"; then
mkdir -p ~/.backup-noctalia
cp -r ~/.config/noctalia ~/.backup-noctalia 2>/dev/null
cp -r ~/.config/quickshell ~/.backup-noctalia 2>/dev/null
ok "Backup feito"
fi

# ===== DEPENDÊNCIAS =====
if ask "Instalar dependências completas?"; then
step "Instalando"

if [ "$PKG" = "pacman" ]; then
sudo pacman -S --noconfirm \
git curl wget unzip \
brightnessctl cava \
wl-clipboard grim slurp \
imagemagick python \
ttf-jetbrains-mono-nerd \
xdg-desktop-portal
else
sudo apt install -y \
git curl wget unzip \
brightnessctl cava \
wl-clipboard grim slurp \
imagemagick python3
fi

ok "Deps OK"
fi

# ===== QUICKSHELL =====
if ask "Instalar Quickshell?"; then
if [ "$PKG" = "pacman" ]; then
read -p "AUR helper: " helper
$helper -S quickshell || fail "Erro quickshell"
else
fail "Instale manualmente"
fi
fi

command -v qs >/dev/null || fail "Quickshell não encontrado"
ok "Quickshell OK"

# ===== INSTALAR NOCTALIA =====
step "Instalando Noctalia"

mkdir -p ~/.config/quickshell/noctalia-shell
curl -L https://github.com/noctalia-dev/noctalia-shell/releases/latest/download/noctalia-latest.tar.gz \
| tar -xz --strip-components=1 -C ~/.config/quickshell/noctalia-shell

ok "Instalado"

# ===== CONFIG MENU =====
mkdir -p ~/.config/noctalia

echo ""
echo "Configuração:"
select theme in dark neon minimal; do break; done

ask "Ativar blur?" && blur=true || blur=false
ask "Ativar animações?" && anim=true || anim=false

cat > ~/.config/noctalia/config.json <<EOF
{
 "theme": "$theme",
 "blur": $blur,
 "animations": $anim,
 "bar": true,
 "launcher": true
}
EOF

ok "Config OK"

# ===== AUTOSTART =====
if ask "Autostart?"; then
case $COMP in
hyprland)
grep -q "noctalia" ~/.config/hypr/hyprland.conf 2>/dev/null || \
echo "exec-once = qs -c noctalia-shell --no-duplicate" >> ~/.config/hypr/hyprland.conf
;;
sway)
grep -q "noctalia" ~/.config/sway/config 2>/dev/null || \
echo "exec qs -c noctalia-shell" >> ~/.config/sway/config
;;
niri)
grep -q "noctalia" ~/.config/niri/config.kdl 2>/dev/null || \
echo 'spawn-at-startup "qs" "-c" "noctalia-shell"' >> ~/.config/niri/config.kdl
;;
esac
ok "Autostart OK"
fi

# ===== DEBUG =====
if ask "Rodar debug?"; then
qs -c noctalia-shell --debug
fi

# ===== FINAL =====
echo ""
echo -e "${G}✔ Instalação concluída${N}"
echo "Log: $LOG"
echo "Reinicie a sessão $COMP"
source ./lib/ui.sh
source ./lib/detect.sh
source ./lib/install.sh
source ./lib/config.sh

logo

PKG=$(detect_pkg)
COMP=$(detect_compositor)

echo "PKG: $PKG"
echo "Compositor: $COMP"

ask "Instalar dependências?" && install_deps $PKG
ask "Configurar?" && setup_config
