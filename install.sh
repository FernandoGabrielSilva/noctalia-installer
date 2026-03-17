#!/bin/bash

set -e

REPO="FernandoGabrielSilva/noctalia-installer"
TMP_DIR="/tmp/noctalia-installer"

echo "=============================="
echo " Noctalia Installer"
echo "=============================="
echo ""

read -p "Deseja continuar? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

echo "Baixando projeto completo..."

rm -rf $TMP_DIR

# Baixa o repo inteiro
if command -v git &>/dev/null; then
    git clone https://github.com/$REPO.git $TMP_DIR
else
    echo "Git não encontrado, usando fallback..."
    curl -L https://github.com/$REPO/archive/refs/heads/main.tar.gz \
    | tar -xz -C /tmp
    mv /tmp/noctalia-installer-main $TMP_DIR
fi

cd $TMP_DIR

chmod +x noctalia-god.sh

echo "Iniciando instalação..."

bash noctalia-god.sh
