#!/bin/bash

set -e

echo "=============================="
echo " Noctalia Installer Loader"
echo "=============================="
echo ""

read -p "Deseja instalar o Noctalia? (y/n): " confirm
[ "$confirm" != "y" ] && exit 0

echo "Baixando e executando instalador..."

# Executa diretamente sem salvar em arquivo
bash -c "$(curl -fsSL https://raw.githubusercontent.com/FernandoGabrielSilva/noctalia-installer/main/noctalia-god.sh)"
