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
echo "╚═╝ ╚═══╝ ╚═════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝"
echo -e "${N}"
echo -e "${G}Noctalia Installer GOD ULTRA${N}"
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
    echo "3) Cancelar"
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
        sudo pacman -S --needed --noconfirm \
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
        read -p "Versão (1=stable / 2=git): " qopt < /dev/tty

        case $qopt in
        1)
            sudo pacman -Rns quickshell-git --noconfirm 2>/dev/null || true
            read -p "AUR helper: " helper < /dev/tty
            $helper -S quickshell || fail "Erro quickshell"
            ;;
        2)
            sudo pacman -Rns quickshell --noconfirm 2>/dev/null || true
            read -p "AUR helper: " helper < /dev/tty
            $helper -S quickshell-git || fail "Erro quickshell-git"
            ;;
        *)
            fail "Opção inválida"
            ;;
        esac
    else
        ok "Mantendo Quickshell atual"
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

# ===== ULTRA DETECTOR =====
step "Detectando outras shells..."

declare -A DETECTED
KEYWORDS=("dank" "waybar" "eww" "ags" "yambar" "polybar" "ironbar")

for file in ~/.config/hypr/hyprland.conf ~/.config/sway/config ~/.config/niri/config.kdl; do
    [ -f "$file" ] || continue
    for key in "${KEYWORDS[@]}"; do
        grep -qi "$key" "$file" && DETECTED["$key"]=1
    done
done

if [ ${#DETECTED[@]} -gt 0 ]; then
    echo -e "${Y}Detectado:${N}"
    for i in "${!DETECTED[@]}"; do echo " - $i"; done

    echo "1) Remover tudo"
    echo "2) Desativar tudo (recomendado)"
    echo "3) Ignorar"
    read -p "Opção: " act < /dev/tty

    for i in "${!DETECTED[@]}"; do
        case $act in
        1)
            rm -rf ~/.config/$i* 2>/dev/null
            sed -i "/$i/d" ~/.config/hypr/hyprland.conf 2>/dev/null
            ;;
        2)
            sed -i "s/^.*$i.*$/# desativado: &/g" ~/.config/hypr/hyprland.conf 2>/dev/null
            ;;
        esac
    done
fi

# ===== CONFIG =====
mkdir -p ~/.config/noctalia

echo "Tema:"
echo "1) dark"
echo "2) neon"
echo "3) minimal"
read -p "Escolha: " opt < /dev/tty

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
 "animations": $anim
}
EOF

ok "Config OK"

# ===== AUTOSTART LIMPO =====
if ask "Ativar Noctalia no autostart?"; then
    sed -i '/noctalia-shell/d' ~/.config/hypr/hyprland.conf 2>/dev/null
    echo "exec-once = qs -c noctalia-shell --no-duplicate" >> ~/.config/hypr/hyprland.conf
    ok "Noctalia padrão definido"
fi

# ===== DEBUG =====
if ask "Rodar debug?"; then
    read -p "Porta (default 1337): " port < /dev/tty
    port=${port:-1337}
    qs -c noctalia-shell --debug $port:$port
fi

# ===== FINAL =====
echo ""
echo -e "${G}✔ Instalação concluída${N}"
echo "Reinicie sua sessão"
