#!/bin/bash

#Debian/Ubuntu
if command -v apt >/dev/null 2>&1; then
    apt update
    apt upgrade -y
fi

#Fedora
if command -v dnf >/dev/null 2>&1; then
    dnf update
    dnf upgrade -y
fi

#Bazzite
if command -v ujust >/dev/null 2>&1; then
    ujust update -y
fi

#Arch
if command -v pacman >/dev/null 2>&1; then
    pacman -Syu --noconfirm
fi

#Flatpak
if command -v flatpak >/dev/null 2>&1; then
    flatpak update -y
fi