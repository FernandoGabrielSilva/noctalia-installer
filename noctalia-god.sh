#!/bin/bash

cd "$(dirname "$0")"

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
