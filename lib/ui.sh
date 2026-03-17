#!/bin/bash

R="\e[31m"; G="\e[32m"; Y="\e[33m"; C="\e[36m"; N="\e[0m"

logo() {
clear
echo -e "${C}Noctalia Installer${N}"
}

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
