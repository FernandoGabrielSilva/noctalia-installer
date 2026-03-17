#!/bin/bash

set -e

LOG="$HOME/noctalia-god.log"
exec > >(tee -a "$LOG") 2>&1

R="\e[31m"; G="\e[32m"; Y="\e[33m"; C="\e[36m"; N="\e[0m"

# ===== PROTEÇÃO ROOT =====
if [ "$EUID" -eq 0 ]; then
  echo -e "${R}Não rode como root!${N}"
  exit 1
fi

# ===== UI =====
clear
echo -e "${C}"
echo "███╗   ██╗ ██████╗  ██████╗████████╗ █████╗ ██╗      ██╗ █████╗ "
echo "████╗  ██║██╔═══██╗██╔════╝╚══██╔══╝██╔══██╗██║     ██║██╔══██╗"
echo "██╔██╗ ██║██║   ██║██║        ██║   ███████║██║     ██║███████║"
echo "██║╚██╗██║██║   ██║██║        ██║   ██╔══██║██║     ██║██╔══██║"
echo "██║ ╚████║╚██████╔╝╚██████╗    ██║   ██║  ██║███████╗██║██║  ██║"
echo "╚═╝  ╚═══╝ ╚═════╝  ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝"
echo -e "${N}"
echo -e "${G}Noctalia Installer GOD${N}"
echo ""

# ===== FUNÇÕES =====
ask() {
while true; do
read -p "$1 (y/n): " yn < /dev/tty
case $yn in
[Yy]*) return 0 ;;
[Nn]*) return 1 ;;
*) echo "Digite y ou n." ;;
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

read -p "Escolha: " opt < /dev/tty

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
echo "1) hyprland"
echo "2) sway"
echo "3) niri"

read -p "Opção: " compopt < /dev/tty

case $compopt in
1) COMP="hyprland" ;;
2) COMP="sway" ;;
3) COMP="niri" ;;
*) fail "Inválido" ;;
esac
fi

ok "Compositor: $COMP"

# ===== BACKUP =====
if ask "Backup configs?"; then
mkdir -p ~/.backup-noctalia
cp -r ~/.config/noctalia ~/.backup-noctalia 2>/dev/null || true
cp -r ~/.config/quickshell ~/.backup-noctalia 2>/dev/null || true
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
if command -v qs &>/dev/null; then
    echo -e "${Y}Quickshell já está instalado!${N}"

    if pacman -Q quickshell-git &>/dev/null; then
        echo "Versão detectada: quickshell-git"
    elif pacman -Q quickshell &>/dev/null; then
        echo "Versão detectada: quickshell"
    fi

    if ask "Deseja reinstalar Quickshell?"; then
        read -p "Escolha versão (1=stable / 2=git): " qopt < /dev/tty

        case $qopt in
        1)
            sudo pacman -Rns quickshell-git --noconfirm 2>/dev/null || true
            read -p "AUR helper (yay/paru): " helper < /dev/tty
            $helper -S quickshell || fail "Erro quickshell"
            ;;
        2)
            sudo pacman -Rns quickshell --noconfirm 2>/dev/null || true
            read -p "AUR helper (yay/paru): " helper < /dev/tty
            $helper -S quickshell-git || fail "Erro quickshell-git"
            ;;
        *)
            fail "Opção inválida"
            ;;
        esac
    else
        ok "Mantendo Quickshell atual"
    fi

else
    if ask "Instalar Quickshell?"; then
        read -p "Versão (1=stable / 2=git): " qopt < /dev/tty
        read -p "AUR helper (yay/paru): " helper < /dev/tty

        case $qopt in
        1) $helper -S quickshell || fail "Erro quickshell" ;;
        2) $helper -S quickshell-git || fail "Erro quickshell-git" ;;
        *) fail "Inválido" ;;
        esac
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

# ===== CONFIG =====
mkdir -p ~/.config/noctalia

echo ""
echo "Configuração:"
echo "1) dark"
echo "2) neon"
echo "3) minimal"

read -p "Tema: " opt < /dev/tty

case $opt in
1) theme="dark" ;;
2) theme="neon" ;;
3) theme="minimal" ;;
*) theme="dark" ;;
esac

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
grep -q "qs -c noctalia-shell" ~/.config/hypr/hyprland.conf 2>/dev/null || \
echo "exec-once = qs -c noctalia-shell --no-duplicate" >> ~/.config/hypr/hyprland.conf
;;
sway)
grep -q "qs -c noctalia-shell" ~/.config/sway/config 2>/dev/null || \
echo "exec qs -c noctalia-shell" >> ~/.config/sway/config
;;
niri)
grep -q "qs -c noctalia-shell" ~/.config/niri/config.kdl 2>/dev/null || \
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
