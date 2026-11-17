#!/bin/bash

if [[ "$@" == "enable" ]]; then

    if systemctl cat zramswap.service &>/dev/null; then
        systemctl disable zramswap.service
        systemctl mask zramswap.service
    fi

    if systemctl cat power-profiles-daemon.service &>/dev/null; then
        systemctl disable power-profiles-daemon.service
        systemctl mask power-profiles-daemon.service
    fi

    if systemctl cat tuned.service &>/dev/null; then
        systemctl disable tuned.service
        systemctl mask tuned.service
    fi

elif [[ "$@" == "disable" ]]; then

    if systemctl cat zramswap.service &>/dev/null; then
        systemctl unmask zramswap.service
        systemctl enable zramswap.service
    fi

    if systemctl cat tuned.service &>/dev/null; then
        systemctl unmask tuned.service
        systemctl enable tuned.service
    else
        if systemctl cat power-profiles-daemon.service &>/dev/null; then
            systemctl unmask power-profiles-daemon.service
            systemctl enable power-profiles-daemon.service
        fi
    fi

fi