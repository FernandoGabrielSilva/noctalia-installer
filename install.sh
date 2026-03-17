#!/bin/bash

set -e

echo "=============================="
echo " Noctalia Installer Loader"
echo "=============================="
echo ""

read -p "Deseja instalar o Noctalia? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

TMP_SCRIPT="/tmp/noctalia-god.sh"

echo "Baixando instalador completo..."

curl -fsSL https://raw.githubusercontent.com/FernandoGabrielSilva/noctalia-installer/main/noctalia-god.sh -o $TMP_SCRIPT

chmod +x $TMP_SCRIPT

echo "Iniciando instalação..."

bash $TMP_SCRIPT
