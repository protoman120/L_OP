#!/bin/bash

#SHOULD NOT BE USED, WORKS HORRIBLY

tmpfs_preload_optimize_hardware(){

    cpu_analysis
    ram_analysis
    storage_analysis
    os_analysis

    if [[ $OPTIMIZATION_CPU_ENABLED == "enabled" ]]; then
        export CPU_OPTIMIZATION_GOAL=throughput
        cpu_optimizations
    fi

    if [[ $OPTIMIZATION_RAM_ENABLED == "enabled" ]]; then
        export RAM_OPTIMIZATION_GOAL=throughput
        ram_optimizations
    fi

    if [[ $OPTIMIZATION_STORAGE_ENABLED == "enabled" ]]; then
        #TEMPORARILY FOCUS ON THROUGHPUT TO REDUCE LOADING TIMES
        export HDD_STORAGE_OPTIMIZATION_GOAL=throughput
        export SSD_STORAGE_OPTIMIZATION_GOAL=throughput
        export USB_STORAGE_OPTIMIZATION_GOAL=throughput
        export NVME_STORAGE_OPTIMIZATION_GOAL=throughput
        storage_optimizations
    fi

    if [[ $OPTIMIZATION_OS_ENABLED == "enabled" ]]; then
        kernel_optimizations
    fi

}

tmpfs_preload_setup(){

    source "$SCRIPT_DIRS_DATA_FILE"

    source "$SCRIPT_OPTIMIZATION_GOALS_FILE"

    tmpfs_preload_optimize_hardware

    export TMPFS_SIZE_LIMIT=$(( $RAM_B / 16 ))
    export TMFS_ARGUMENTS="mode=1777,noatime"
    
    export MAIN_TMPFS_PRELOAD_DIR="${SCRIPT_TMPFS_DATA}/TMPFS_PRELOADED_DATA"

    mkdir -p "$MAIN_TMPFS_PRELOAD_DIR"

    if [ -e "$MAIN_TMPFS_PRELOAD_DIR" ]; then
            mount -t tmpfs -o "$TMFS_ARGUMENTS" tmpfs "$MAIN_TMPFS_PRELOAD_DIR"
    fi

    if [[ "$OPTIMIZATION_PROFILE_USECASE" != "server" ]]; then
        tmpfs_preload_desktop_environment
        tmpfs_preload_graphics
    fi

    tmpfs_preload_generic_dirs
    tmpfs_preload_shared_libraries
    tmpfs_preload_applications
    
    chmod -R 1777 "$MAIN_TMPFS_PRELOAD_DIR"
    #THIS IS DONE TO AVOID BREAKING SUDO
    chown -R root:root /etc/sudo
    chmod -R 4755 /etc/sudo
    chown -R root:root /etc/sudo.conf
    chmod -R 4755 /etc/sudo.conf
    chown -R root:root /etc/sudoers
    chmod -R 4755 /etc/sudoers
    chown -R root:root /etc/sudoers.d
    chmod -R 4755 /etc/sudoers.d
    chown -R root:root /usr/bin/sudo
    chmod -R 4755 /usr/bin/sudo

}

tmpfs_preload_dir(){

	local SYSTEM_DIR="$1"
    local TMPFS_FOLDER_DIR="$2"

	[[ -e "$SYSTEM_DIR" ]] || return 0

	local SYSTEM_DIR_SIZE=$(du -sb "$SYSTEM_DIR" | awk '{print $1}')

	local TOTAL_PRELOAD_SIZE_TEMP=$(( $TOTAL_PRELOAD_SIZE + $SYSTEM_DIR_SIZE ))
	
	if (( $TOTAL_PRELOAD_SIZE_TEMP <= $TMPFS_SIZE_LIMIT )); then
	
		export TOTAL_PRELOAD_SIZE=$TOTAL_PRELOAD_SIZE_TEMP
		local TMPFS_DIR="${TMPFS_FOLDER_DIR}${SYSTEM_DIR}"
		mkdir -p "$TMPFS_DIR"
		#mount -t tmpfs -o "$TMFS_ARGUMENTS" tmpfs "$TMPFS_DIR"

		if [[ -d "$SYSTEM_DIR" ]]; then
			cp -a "$SYSTEM_DIR"/. "$TMPFS_DIR"/
			mount --bind "$TMPFS_DIR" "$SYSTEM_DIR"
		else
			cp -a "$SYSTEM_DIR" "$TMPFS_DIR/$(basename "$SYSTEM_DIR")"
			mount --bind "$TMPFS_DIR/$(basename "$SYSTEM_DIR")" "$SYSTEM_DIR"
		fi

	fi
}

tmpfs_preload_generic_dirs(){

    source "$SCRIPT_DIRS_DATA_FILE"
    source "$SCRIPT_OPTIMIZATION_GOALS_FILE"

    TMPFS_GENERIC_PRELOAD_DATA="$MAIN_TMPFS_PRELOAD_DIR/GENERIC_TMPFS_DATA"

    mkdir -p "$TMPFS_GENERIC_PRELOAD_DATA"

    GENERIC_PRELOAD_DIRS=()

    GENERIC_PRELOAD_DIRS=(
        "/lib"
        "/lib64"
        "/usr/lib"
        "/usr/lib64"

        "/bin"
        "/sbin"
        "/usr/sbin"

        "/etc"
        "/usr/bin"

        "/usr/share"

        "/usr/lib/systemd"
    )

    for SYSTEM_DIR in "${GENERIC_PRELOAD_DIRS[@]}"; do
        tmpfs_preload_dir "$SYSTEM_DIR" "$TMPFS_GENERIC_PRELOAD_DATA"
    done

}

tmpfs_preload_desktop_environment(){

    source "$SCRIPT_DIRS_DATA_FILE"
    source "$SCRIPT_OPTIMIZATION_GOALS_FILE"
    source "$SCRIPT_SAVED_DE_DATA_FILE"

    TMPFS_DE_PRELOAD_DATA="$MAIN_TMPFS_PRELOAD_DIR/DE_TMPFS_DATA"

    mkdir -p "$TMPFS_DE_PRELOAD_DATA"

    DE_PATHS=()
    
    #GENERIC DE PATHS
    DE_PATHS+=(
        "/usr/share/icons"
        "/usr/share/themes"
        "/usr/share/fonts"
        "/usr/share/mime"
        "/usr/share/glib-2.0"
    )

    if [[ "$XFCE_INSTALLED" == "true" ]]; then
    	DE_PATHS+=(
        	"/usr/share/xfce4"
        )
    fi
    
    if [[ "$CINNAMON_INSTALLED" == "true" ]]; then
    	DE_PATHS+=(
                "/usr/share/cinnamon"
        )
    fi
    
    if [[ "$GNOME_INSTALLED" == "true" ]]; then
    	DE_PATHS+=(
                "/usr/share/gnome-shell"
                "/usr/share/gnome"
                "/usr/share/backgrounds"
        )
    fi
    
    if [[ "$KDE_INSTALLED" == "true" ]]; then
    	DE_PATHS+=(
                "/usr/share/plasma"
                "/usr/share/kwin"
                "/usr/share/kservices5"
                "/usr/share/color-schemes"
    	)
    fi

    for SYSTEM_DIR in "${DE_PATHS[@]}"; do
        tmpfs_preload_dir "$SYSTEM_DIR" "$TMPFS_DE_PRELOAD_DATA"
    done

}

tmpfs_preload_graphics(){

    source "$SCRIPT_DIRS_DATA_FILE"
    source "$SCRIPT_OPTIMIZATION_GOALS_FILE"

    TMPFS_GRAPHICS_PRELOAD_DATA="$MAIN_TMPFS_PRELOAD_DIR/GRAPHICS_TMPFS_DATA"

    mkdir -p "$TMPFS_GRAPHICS_PRELOAD_DATA"

    GRAPHICS_PATHS=(
        "/usr/share/X11"
        "/usr/share/wayland"
        "/usr/share/wayland-sessions"
        "/usr/share/vulkan"
        "/usr/share/drirc.d"
    )

    for SYSTEM_DIR in "${GRAPHICS_PATHS[@]}"; do
        tmpfs_preload_dir "$SYSTEM_DIR" "$TMPFS_GRAPHICS_PRELOAD_DATA"
    done

}

tmpfs_preload_applications(){

    source "$SCRIPT_DIRS_DATA_FILE"
    source "$SCRIPT_OPTIMIZATION_GOALS_FILE"

    TMPFS_APP_PRELOAD_DATA="$MAIN_TMPFS_PRELOAD_DIR/APPLICATION_TMPFS_DATA"

    mkdir -p "$TMPFS_APP_PRELOAD_DATA"

    APPLICATIONS=(
        "/usr/bin/bash"
    )

    if [[ "$OPTIMIZATION_PROFILE_USECASE" != "server" ]]; then
    	APPLICATIONS+=(
                "/usr/bin/firefox"
                "/usr/bin/steam"
                "/usr/bin/flatpak"
                "/usr/bin/kitty"
                "/usr/bin/konsole"
                "/usr/bin/gnome-shell"
                "/usr/bin/plasmashell"
                "/usr/bin/xfwm4"
    	)
    fi

    for SYSTEM_DIR in "${APPLICATIONS[@]}"; do
        tmpfs_preload_dir "$SYSTEM_DIR" "$TMPFS_APP_PRELOAD_DATA"
    done

}

tmpfs_preload_shared_libraries(){

    source "$SCRIPT_DIRS_DATA_FILE"
    source "$SCRIPT_OPTIMIZATION_GOALS_FILE"

    TMPFS_LIB_PRELOAD_DATA="$MAIN_TMPFS_PRELOAD_DIR/LIBRARY_TMPFS_DATA"

    mkdir -p "$TMPFS_LIB_PRELOAD_DATA"

    APPLICATIONS=(
        "/usr/bin/bash"
    )

    if [[ "$OPTIMIZATION_PROFILE_USECASE" != "server" ]]; then
    	APPLICATIONS+=(
                "/usr/bin/firefox"
                "/usr/bin/steam"
                "/usr/bin/flatpak"
                "/usr/bin/plasmashell"
                "/usr/bin/gnome-shell"
                "/usr/bin/xfwm4"
    	)
    fi

    for SYSTEM_DIR in "${APPLICATIONS[@]}"; do
        [[ -e "$SYSTEM_DIR" ]] || continue
        while read -r LIB; do
            [[ -n "$LIB" && -e "$LIB" ]] && tmpfs_preload_dir "$LIB" "$TMPFS_LIB_PRELOAD_DATA"
        done < <(ldd "$SYSTEM_DIR" 2>/dev/null | awk '{print $3}')
    done
    
}
