#!/bin/bash

#############################################################################
#IMPORTANT: SCRIPT DIRS SETUP (OPTIMIZATIONS - MAIN/TMFPS SCRIPT ONLY)
cd /var/lib/L_OP_DEV
source ./utility_scripts/script_directories.sh
source $SAVED_OPTIMIZATION_GOALS
#############################################################################

tmpfs_cache_dir(){

    source "$SCRIPT_DIRS_DATA_FILE"

    local SYSTEM_DIR="$1"
    local TMPFS_FOLDER_DIR="$2"

    if [ -e "$SYSTEM_DIR" ]; then
            
            local TMPFS_DIR="${TMPFS_FOLDER_DIR}${SYSTEM_DIR}"

            mkdir -p "$TMPFS_DIR"

            #mount -t tmpfs -o "$TMFS_ARGUMENTS" tmpfs "$TMPFS_DIR"
            mount --bind "$TMPFS_DIR" "$SYSTEM_DIR"

    fi

}

source "$SCRIPT_DIRS_DATA_FILE"
source "$SCRIPT_OPTIMIZATION_GOALS_FILE"

export TMFS_ARGUMENTS="mode=1777,noatime,x-gvfs-hide,x-gdu-hide"

export MAIN_TMPFS_CACHE_DIR="${SCRIPT_TMPFS_DATA}/TMPFS_CACHED_DATA"

mkdir -p "$MAIN_TMPFS_CACHE_DIR"

if [ -e "$MAIN_TMPFS_CACHE_DIR" ]; then
        mount -t tmpfs -o "$TMFS_ARGUMENTS" tmpfs "$MAIN_TMPFS_CACHE_DIR"
fi

if [[ "$TMPFS_SYSTEM_CACHING" == "enabled" ]]; then
    SYSTEM_CACHE_DIRS=()

    #CACHING "/var/cache" BREAKS LINUX MINT'S UPDATE MANAGER, MAYBE OTHERS TOO
    #"/var/cache"

    SYSTEM_CACHE_DIRS+=(
        "/tmp"
        "/dev/shm"
        "/var/log"
        #CACHING "/var/cache" BREAKS LINUX MINT'S UPDATE MANAGER, MAYBE OTHERS TOO
        #"/var/cache"
        "/var/lib/systemd/coredump"
        "/var/crash"
        
        "/var/cache/debconf"
        "/var/cache/ldconfig"
        "/var/cache/man"
        "/var/cache/fwupd"
        "/var/cache/PackageKit"
        "/var/lib/snapd/cache"
        "/var/cache/debconf"
        
        "/home/$SYSTEM_USER/.cache"
    )

    OTHER_CACHE_DIRS+=(
        "/home/$SYSTEM_USER/.config/*/cache"
        "/home/$SYSTEM_USER/.config/*/cache*"
        "/home/$SYSTEM_USER/.config/*/*cache"
        "/home/$SYSTEM_USER/.config/*/*cache*"
        "/home/$SYSTEM_USER/.config/*/Cache"
        "/home/$SYSTEM_USER/.config/*/Cache*"
        "/home/$SYSTEM_USER/.config/*/*Cache"
        "/home/$SYSTEM_USER/.config/*/*Cache*"
    )

    for OTHER_CACHES in "${OTHER_CACHE_DIRS[@]}"; do
            SYSTEM_CACHE_DIRS+=(
                #NOTE: DO NOT USE "$OTHER_CACHES" WITH "" AS THE /*/ WILL NOT BE REPLACED BY THE DIFFERENT FOLDER NAMES AND THUS NOT WORK
                $OTHER_CACHES
            )
    done

    if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]] || [[ $STORAGE_ROOT_DEVICE_TYPE == "hdd" ]] ; then
        for FLATPAK_CACHE_DIR in "/home/$SYSTEM_USER/.var/app/*/cache"; do
                SYSTEM_CACHE_DIRS+=(
                    #NOTE: DO NOT USE "$FLATPAK_CACHE_DIR" WITH "" AS THE /*/ WILL NOT BE REPLACED BY THE DIFFERENT FOLDER NAMES AND THUS NOT WORK
                    $FLATPAK_CACHE_DIR
                )
        done
    fi

    if [[ "$OPTIMIZATION_PROFILE_USECASE" == "gaming" ]]; then
        if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]] || [[ $STORAGE_ROOT_DEVICE_TYPE == "hdd" ]] ; then

            HEROIC_CACHE_DIRS=(
                "/home/$SYSTEM_USER/.config/heroic/GPUCache"
                "/home/$SYSTEM_USER/.config/heroic/Cache"
                "/home/$SYSTEM_USER/Games/Heroic/Prefixes/*/shadercache"
            )

            for HEROIC_SHADERCACHE_DIR in "${HEROIC_CACHE_DIRS[@]}"; do
                    SYSTEM_CACHE_DIRS+=(
                        $HEROIC_SHADERCACHE_DIR
                    )
            done

            STEAM_CACHE_DIRS=(
                "/home/$SYSTEM_USER/.local/share/Steam/steamapps/shadercache"
                "/home/$SYSTEM_USER/.steam/steam/appcache"
                "/home/$SYSTEM_USER/.steam/debian-installation/steamapps/shadercache"
                "/home/$SYSTEM_USER/.steam/debian-installation/appcache"
                "/mnt/*/SteamLibrary/steamapps/shadercache"
            )

            for STEAM_CACHE_DIR in "${STEAM_CACHE_DIRS[@]}"; do
                    SYSTEM_CACHE_DIRS+=(
                        $STEAM_CACHE_DIR
                    )
            done

            PRISM_LAUNCHER_MINECRAFT_CACHE_DIRS=(
                "/home/$SYSTEM_USER/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/cache"
                "/home/$SYSTEM_USER/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/tmp"
                "/home/$SYSTEM_USER/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/cache"
                "/home/$SYSTEM_USER/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/.cache"
                "/home/$SYSTEM_USER/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/*/.cache"
                "/home/$SYSTEM_USER/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/config/*/cache"
                "/home/$SYSTEM_USER/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/*/minecraft/config/*/.cache"
            )

            for PRISM_LAUNCHER_MINECRAFT_CACHE_DIR in "${PRISM_LAUNCHER_MINECRAFT_CACHE_DIRS[@]}"; do
                    SYSTEM_CACHE_DIRS+=(
                        #NOTE: DO NOT USE "$PUFFERPANEL_MINECRAFT_CACHE_DIR" WITH "" AS THE /*/ WILL NOT BE REPLACED BY THE DIFFERENT FOLDER NAMES AND THUS NOT WORK
                        $PUFFERPANEL_MINECRAFT_CACHE_DIR
                    )
            done

        fi
    fi

    if [[ "$OPTIMIZATION_PROFILE_USECASE" == "server" ]]; then
        PUFFERPANEL_MINECRAFT_SERVER_CACHE_DIRS=(
            "/var/lib/pufferpanel/cache"

            #IF USED, SERVERS CANNOT BE RESTARTED UNLESS A FULL SYSTEM REBOOT IS DONE
            #"/var/lib/pufferpanel/servers/*/logs"
            #"/var/lib/pufferpanel/servers/*/tmp"
            #"/var/lib/pufferpanel/servers/*/cache"
            #"/var/lib/pufferpanel/servers/*/.cache"
            #"/var/lib/pufferpanel/servers/*/*/.cache"
            #"/var/lib/pufferpanel/servers/*/config/*/cache"
            #"/var/lib/pufferpanel/servers/*/config/*/.cache"
        )

        for PUFFERPANEL_MINECRAFT_CACHE_DIR in "${PUFFERPANEL_MINECRAFT_SERVER_CACHE_DIRS[@]}"; do
                SYSTEM_CACHE_DIRS+=(
                    #NOTE: DO NOT USE "$PUFFERPANEL_MINECRAFT_CACHE_DIR" WITH "" AS THE /*/ WILL NOT BE REPLACED BY THE DIFFERENT FOLDER NAMES AND THUS NOT WORK
                    $PUFFERPANEL_MINECRAFT_CACHE_DIR
                )
        done
    fi

    for SYSTEM_DIR in "${SYSTEM_CACHE_DIRS[@]}"; do
        tmpfs_cache_dir "$SYSTEM_DIR" "$MAIN_TMPFS_CACHE_DIR"
        mount -o remount,bind,x-gvfs-hide "$SYSTEM_DIR"
    done

fi

chmod -R 1777 "$MAIN_TMPFS_CACHE_DIR"