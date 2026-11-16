#!/bin/bash

if [[ "$@" == "enable" ]]; then

    if systemctl cat zramswap.service &>/dev/null; then
        systemctl disable zramswap.service
    fi

    if systemctl cat power-profiles-daemon.service &>/dev/null; then
        systemctl disable power-profiles-daemon.service
    fi

    if systemctl cat tuned.service &>/dev/null; then
        systemctl disable tuned.service
    fi

elif [[ "$@" == "disable" ]]; then

    if systemctl cat zramswap.service &>/dev/null; then
        systemctl enable zramswap.service
    fi

    if systemctl cat power-profiles-daemon.service &>/dev/null; then
        systemctl enable power-profiles-daemon.service
    fi

    if systemctl cat tuned.service &>/dev/null; then
        systemctl enable tuned.service
    fi

fi