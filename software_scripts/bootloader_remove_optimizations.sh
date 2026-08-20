#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP (OPTIMIZATIONS)
source ./utility_scripts/script_directories.sh
source $SAVED_OPTIMIZATION_GOALS
source $SAVED_CPU_DATA
source $SAVED_GPU_DATA
source $SAVED_RAM_DATA
source $SAVED_ROOT_STORAGE_DATA
source $SAVED_OS_DATA
source $SAVED_DE_DATA
source $SAVED_BOOTLOADER_DATA
##################################################################

if command -v grub-mkconfig >/dev/null 2>&1 || command -v update-grub >/dev/null 2>&1; then
    BOOTLOADER_GRUB_INSTALLED="true"
fi

if [[ $BOOTLOADER_GRUB_INSTALLED == "true" ]];then
    GRUB_BASE_ARGS="quiet splash noatime"
    BOOTLOADER_NEW_GRUB_ARGS="${GRUB_BASE_ARGS}"
    sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$BOOTLOADER_NEW_GRUB_ARGS\"|" "$SYSTEM_GRUB_FILE"
    update-grub
fi