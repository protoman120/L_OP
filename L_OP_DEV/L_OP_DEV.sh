#!/bin/bash

#L_OP MAIN SCRIPT

if [[ $EUID -ne 0 ]]; then
    echo "This script requires root access to function, please restart it with sudo."
    exit 1
fi

script_system_hardware_analysis(){
    $CPU_ANALYSIS
	$GPU_ANALYSIS
	$RAM_ANALYSIS
	$STORAGE_ANALYSIS
}

script_system_software_analysis(){
    $OS_ANALYSIS
}

script_system_user_software_analysis(){
    $DE_ANALYSIS
}

script_system_hardware_optimizations(){

    if [[ $OPTIMIZATION_CPU_ENABLED == "enabled" ]]; then
        $CPU_OPTIMIZATIONS
    fi

    if [[ $OPTIMIZATION_GPU_ENABLED == "enabled" ]]; then
        $GPU_OPTIMIZATIONS
    fi
    
    if [[ $OPTIMIZATION_RAM_ENABLED == "enabled" ]]; then
        $RAM_OPTIMIZATIONS
    fi

    if [[ $OPTIMIZATION_STORAGE_ENABLED == "enabled" ]]; then
        $STORAGE_OPTIMIZATIONS
        $STORAGE_ANALYSIS
    fi

}

script_system_software_optimizations(){
    
    if [[ $OPTIMIZATION_OS_ENABLED == "enabled" ]]; then
        $KERNEL_OPTIMIZATIONS
    fi
    
    if [[ $OPTIMIZATION_NETWORK_ENABLED == "enabled" ]]; then
        $NETWORK_OPTIMIZATIONS
    fi

    if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" ]]; then
        #$BOOTLOADER_OPTIMIZATIONS
        echo ""
    fi

}

script_system_user_software_optimizations(){

    if [[ $OPTIMIZATION_DE_ENABLED == "enabled" ]]; then
        #$DE_OPTIMIZATIONS
        echo ""
    fi

}

pc_info(){
	MENU_SPACING="#############"

	echo ""
	echo "$MENU_SPACING $SCRIPT_NAME $MENU_SPACING"
	echo ""
	echo "PC SPECS:"
	echo ""
	
	echo "CPU:"
	echo "	- MODEL: $CPU_MODEL"
	echo "	- VENDOR ID: $CPU_VENDOR_ID"
	
	if (( CPU_MULTITHREADING_ENABLED > 1 )); then
		echo "	- MULTITHREADING: ENABLED"
	else
		echo "	- MULTITHREADING: DISABLED"
	fi
	
	echo "	- CORES: $CPU_CORES"
	echo "	- THREADS: $CPU_THREADS"

	if (( CPU_MIN_FREQ > 1000000 )); then
		echo "	- MIN. FREQ.: $CPU_MIN_FREQ_HUMAN_READABLE_GHZ Ghz"
	else
		echo "	- MIN. FREQ.: $CPU_MIN_FREQ_HUMAN_READABLE_MHZ Mhz"
	fi

	if (( CPU_MAX_FREQ > 1000000 )); then
		echo "	- MAX. FREQ.: $CPU_MAX_FREQ_HUMAN_READABLE_GHZ Ghz"
	else
		echo "	- MAX. FREQ.: $CPU_MAX_FREQ_HUMAN_READABLE_MHZ Mhz"
	fi
	
	if [[ "$CPU_VENDOR_ID" == "GenuineIntel" ]]; then
		echo "	- MAX TDP: $(($CURRENT_CPU_TDP_INTEL_HUMAN_READABLE+1)) W"
	fi
	
	echo "	- L3 CACHE: $CPU_L3_CACHE_SIZE_MB MB"
	echo "	- L2 CACHE: $CPU_L2_CACHE_SIZE_MB MB"
	
	if [[ "$CPU_L1D_CACHE_SIZE_KB" == "$CPU_L1I_CACHE_SIZE_KB" ]]; then
		echo "	- L1 CACHE: $CPU_L1D_CACHE_SIZE_KB KB"
	else
		echo "	- L1D (L1 DATA) CACHE: $CPU_L1D_CACHE_SIZE_KB KB"
		echo "	- L1I (L1 INSTRUCTION) CACHE: $CPU_L1I_CACHE_SIZE_KB KB"
	fi
	
	echo ""
	echo "RAM:"
	echo "	- AMOUNT: $RAM_GB_PHYSICAL GB"
	echo "	- GENERATION: $RAM_GENERATION"
	echo "	- SPEED: $RAM_SPEED MT/S"
	
	echo ""
	echo "OS:"
	if [[ "$SYSTEM_DISTRO_BASE_1" != "" ]]; then
		echo "	- DISTRIBUTION: $SYSTEM_CURRENT_DISTRO_VERSION ($SYSTEM_DISTRO_BASE_1 based)"
	else
		echo "	- DISTRIBUTION: $SYSTEM_CURRENT_DISTRO_VERSION"
	fi
	echo "	- KERNEL VERSION: $SYSTEM_KERNEL_VERSION"
    
    if [[ "$TESTING_MODE" == "true" ]]; then
         echo ""
         echo "${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}"
         echo "WARNING: TESTING MODE ENABLED, OPTIMIZATIONS SELECTED WILL NOT BE APPLIED"
         echo "PC ANALYSIS DATA WILL BE SAVED ON /home/${SYSTEM_USER}"
         echo "${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}"
    fi
}

profile_save_optimization_goals() {

    cat > "$SAVED_OPTIMIZATION_GOALS" <<EOF
        #SYSTEM USER

        export SYSTEM_USER=$(printf '%q' "$SYSTEM_USER")
        export SYSTEM_SETUP_USER=$(printf '%q' "$SYSTEM_SETUP_USER")

        SYSTEM_AUTOMATIC_UPDATES=$(printf '%q' "$SYSTEM_AUTOMATIC_UPDATES")
        SYSTEM_PORTABLE_INSTALL=$(printf '%q' "$SYSTEM_PORTABLE_INSTALL")

        #SCANNED HARDWARE (TO USE AS REFERENCE FOR PORTABLE INSTALLS)
        
        STORAGE_ROOT_DEVICE_TYPE=$(printf '%q' "$STORAGE_ROOT_DEVICE_TYPE")
        SCANNED_SYSTEM_SWAP_PARTITION_DETECTED=$(printf '%q' "$SYSTEM_SWAP_PARTITION_DETECTED")
        SCANNED_CPU_CLASSIFICATION=$(printf '%q' "$CPU_CLASS")
        SCANNED_RAM_CLASSIFICATION=$(printf '%q' "$RAM_CLASS")

        #SELECTED PROFILE:

        OPTIMIZATION_PROFILE=$(printf '%q' "$OPTIMIZATION_PROFILE")
        OPTIMIZATION_PROFILE_USECASE=$(printf '%q' "$OPTIMIZATION_PROFILE_USECASE") 

        #HARDWARE OPTIMIZATIONS:
	
        #CPU OPTIMIZATIONS:
        OPTIMIZATION_CPU_ENABLED=$(printf '%q' "$OPTIMIZATION_CPU_ENABLED")      
        CPU_OPTIMIZATION_GOAL=$(printf '%q' "$CPU_OPTIMIZATION_GOAL")
        CPU_COOLING_OPTIMIZATION=$(printf '%q' "$CPU_COOLING_OPTIMIZATION")

        #GPU OPTIMIZATIONS:
        OPTIMIZATION_GPU_ENABLED=$(printf '%q' "$OPTIMIZATION_GPU_ENABLED")
        GPU_OPTIMIZATION_GOAL=$(printf '%q' "$GPU_OPTIMIZATION_GOAL")
        GPU_COOLING_OPTIMIZATION=$(printf '%q' "$GPU_COOLING_OPTIMIZATION")

        #RAM OPTIMIZATIONS:
        OPTIMIZATION_RAM_ENABLED=$(printf '%q' "$OPTIMIZATION_RAM_ENABLED")
        RAM_OPTIMIZATION_GOAL=$(printf '%q' "$RAM_OPTIMIZATION_GOAL")

        #NETWORK OPTIMIZATIONS:
        OPTIMIZATION_NETWORK_ENABLED=$(printf '%q' "$OPTIMIZATION_NETWORK_ENABLED")
        NETWORK_OPTIMIZATION_GOAL=$(printf '%q' "$NETWORK_OPTIMIZATION_GOAL")

        #STORAGE_OPTIMIZATIONS:
        OPTIMIZATION_STORAGE_ENABLED=$(printf '%q' "$OPTIMIZATION_STORAGE_ENABLED")
        HDD_STORAGE_OPTIMIZATION_GOAL=$(printf '%q' "$HDD_STORAGE_OPTIMIZATION_GOAL")
        SSD_STORAGE_OPTIMIZATION_GOAL=$(printf '%q' "$SSD_STORAGE_OPTIMIZATION_GOAL")
        USB_STORAGE_OPTIMIZATION_GOAL=$(printf '%q' "$USB_STORAGE_OPTIMIZATION_GOAL")
        NVME_STORAGE_OPTIMIZATION_GOAL=$(printf '%q' "$NVME_STORAGE_OPTIMIZATION_GOAL")

        #SOFTWARE OPTIMIZATIONS:
        OPTIMIZATION_OS_ENABLED=$(printf '%q' "$OPTIMIZATION_OS_ENABLED")
        OPTIMIZATION_TMPFS_CACHING_ENABLED=$(printf '%q' "$OPTIMIZATION_TMPFS_CACHING_ENABLED")
        TMPFS_SYSTEM_CACHING=$(printf '%q' "$TMPFS_SYSTEM_CACHING")
        TMPFS_GAMING_CACHING=$(printf '%q' "$TMPFS_GAMING_CACHING")
        OPTIMIZATION_DE_ENABLED=$(printf '%q' "$OPTIMIZATION_DE_ENABLED")
        OPTIMIZATION_BOOTLOADER_ENABLED=$(printf '%q' "$OPTIMIZATION_BOOTLOADER_ENABLED")
EOF

}

profile_selection_ui() {

    FILECOUNTER=1

    if [[ $BASIC_INSTALL_SCRIPT == "true" ]]; then
        DIR=$SCRIPT_BASIC_PROFILES
    elif [[ $SCRIPT_UTILITIES_SETUP == "true" ]]; then
        DIR=$SCRIPT_EXTRA_UTILITY_SCRIPTS
    else
        DIR=$SCRIPT_PROFILES
    fi

    for FOUNDFILE in $DIR/*; do
        if [[ -f "$FOUNDFILE" ]]; then
            FILENAME[$FILECOUNTER]=$FOUNDFILE
	   		echo "$FILECOUNTER -> $(basename "$FOUNDFILE")"
		    ((FILECOUNTER++))
		fi
	done

    if [[ $INSTALL_SCRIPT == "true" && $BASIC_INSTALL_SCRIPT != "true" && $SCRIPT_UTILITIES_SETUP != "true" ]]; then
        echo "$FILECOUNTER -> Basic profiles"
    elif [[ $BASIC_INSTALL_SCRIPT == "true" && $SCRIPT_UTILITIES_SETUP != "true" ]]; then
        echo "$FILECOUNTER -> Regular profiles"
    fi

    echo "Select a profile:"
	read PROFILE_SELECTION
	while (($PROFILE_SELECTION > $FILECOUNTER)); do
		echo "ERROR: The selection is invalid."
        echo "Select a profile:"
	    read PROFILE_SELECTION
	done
    SELECTED_PROFILE="${FILENAME[$PROFILE_SELECTION]}"

    if [[ $BASIC_INSTALL_SCRIPT != "true" && $SCRIPT_UTILITIES_SETUP != "true" ]]; then
        if (( $PROFILE_SELECTION == $FILECOUNTER )); then
            BASIC_INSTALL_SCRIPT="true"
            profile_selection_ui
        else
            source $SELECTED_PROFILE
        fi
    elif [[ $BASIC_INSTALL_SCRIPT == "true" && $SCRIPT_UTILITIES_SETUP != "true" ]]; then
        if (( $PROFILE_SELECTION == $FILECOUNTER )); then
            BASIC_INSTALL_SCRIPT="false"
            profile_selection_ui
        else
            source $SELECTED_PROFILE
        fi
    else
        if [[ $SCRIPT_UTILITIES_SETUP == "true" ]]; then
            $SELECTED_PROFILE
        else
            source $SELECTED_PROFILE
        fi
    fi
}

script_utilities_menu(){
    UTILITIES_SETUP="true"
	profile_selection_ui
}

uninstall_script(){

    if [ -e $SCRIPT_INSTALLED_DIR ]; then
        rm -r $SCRIPT_SAVED_DATA
        rm -r $SCRIPT_INSTALLED_DIR
        if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" ]]; then
            $BOOTLOADER_REMOVE_OPTIMIZATIONS
        fi
        $SCRIPT_REMOVE_SERVICES
        $TMPFS_CACHING_SERVICES_REMOVAL

        if [[ $INSTALLING_SCRIPT != "true" ]]; then
            ask_system_reboot
        fi
    else
        echo "SCRIPT NOT INSTALLED"
        echo "If you belive this is a mistake, manually delete $SCRIPT_INSTALLED_DIR"
        echo "Then report the bug"
        return 0
    fi

}

install_script(){

	#PROFILE SELECTION
	profile_selection_ui
    #profile_selection_simple

    if [ -e $SCRIPT_INSTALLED_DIR ]; then
        echo "L_OP ALREADY INSTALLED, UNINSTALL FIRST, THEN REINSTALL"
        return 0
    fi

    if [ -e "$SCRIPT_SAVED_DATA" ]; then
        echo ""
    else
        mkdir -p "$SCRIPT_SAVED_DATA"
    fi

	script_system_hardware_analysis
    script_system_software_analysis
    script_system_user_software_analysis

    source $SAVED_ROOT_STORAGE_DATA
    if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
        while true; do
            read -rp "USB device detected as root storage, is this a portable install? (Y/N): " answer
            case "$answer" in
                [Yy])
                    SYSTEM_PORTABLE_INSTALL="true"
                    break
                    ;;
                [Nn])
                    SYSTEM_PORTABLE_INSTALL="false"
                    break
                    ;;
                *)
                    echo ""
                    ;;
            esac
        done
    else
        SYSTEM_PORTABLE_INSTALL="false"
    fi

    while true; do
        read -rp "Do you want to enable automatic updates at boot? (Y/N): " answer
        case "$answer" in
            [Yy])
                SYSTEM_AUTOMATIC_UPDATES="true"
                break
                ;;
            [Nn])
                SYSTEM_AUTOMATIC_UPDATES="false"
                break
                ;;
            *)
                echo ""
                ;;
        esac
    done

    source $SAVED_CPU_DATA
    source $SAVED_RAM_DATA

    #DISABLES FUNCTIONALITY THAT NEEDS A REWORK
    if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" ]]; then
        OPTIMIZATION_BOOTLOADER_ENABLED="disabled_until_reworked"
    fi
    if [[ $OPTIMIZATION_DE_ENABLED == "enabled" ]]; then
        OPTIMIZATION_DE_ENABLED="disabled_until_reworked"
    fi

    #THIS IS HERE BECOUSE THIS FILE INCLUDES THE SELECTION FOR PORTABLE INSTALL AND AUTO UPDATES
    profile_save_optimization_goals

    cp -r $SCRIPT_MAIN_FOLDER $SCRIPT_INSTALL_DIR

    #SERVICES SETUP
    $SCRIPT_SETUP_SERVICES
    $TMPFS_CACHING_SERVICES_SETUP

    #HAS TO BE APPLIED HERE SO IT'S APPLIED ON REBOOT
    if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" ]]; then
        #$BOOTLOADER_OPTIMIZATIONS
        echo ""
    fi

	ask_system_reboot

}

ask_system_reboot(){
    while true; do
        read -rp "Changes applied, a reboot is required to apply them, reboot now? (Y/N): " answer
        case "$answer" in
            [Yy])
                reboot
                break
                ;;
            [Nn])
                echo "Changes will be applied on next reboot"
                break
                ;;
            *)
                echo ""
                ;;
        esac
    done
}

script_main_menu(){

	SCRIPT_MENU_TITLE_BARS="###################################"

    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME"
    echo "$SCRIPT_MENU_TITLE_BARS"

    echo ""
    echo "Available Options:"
    PS3='Choose an option: '
    options=("Install" "Uninstall" "Change_Profile" "Toggle_Automatic_Updates" "Other_Utilties" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Install")
                INSTALLING_SCRIPT="true"
                echo "$SCRIPT_MENU_TITLE_BARS"
                echo "$SCRIPT_NAME: PROFILE SELECTION"
                echo "$SCRIPT_MENU_TITLE_BARS"
                INSTALL_SCRIPT="true"
                install_script
                break
                ;;
            "Uninstall")
                if [ -e $SCRIPT_INSTALLED_DIR ]; then
                    echo "$SCRIPT_MENU_TITLE_BARS"
                    echo "$SCRIPT_NAME: UNINSTALLING"
                    echo "$SCRIPT_MENU_TITLE_BARS"
				    uninstall_script
                    echo "L_OP UNINSTALLED"
                else
                    echo "L_OP NOT INSTALLED"
                fi
				break
                ;;
            "Change_Profile")
                if [ -e $SCRIPT_INSTALLED_DIR ]; then
                    cd /var/lib/L_OP_DEV
                    source ./utility_scripts/script_directories.sh
                    source $SAVED_OPTIMIZATION_GOALS
                    echo "$SCRIPT_MENU_TITLE_BARS"
                    echo "$SCRIPT_NAME: CHANGE PROFILE"
                    echo "$SCRIPT_MENU_TITLE_BARS"
                    INSTALL_SCRIPT="true"
                    profile_selection_ui
                    if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" && BASIC_INSTALL_SCRIPT="true" ]]; then
                        #$BOOTLOADER_REMOVE_OPTIMIZATIONS
                        echo ""
                    fi
                    profile_save_optimization_goals
                    ask_system_reboot
                else
                    echo "SCRIPT NOT INSTALLED, CANNOT CHANGE PROFILE, PLEASE INSTALL FIRST"
                    return 0
                fi
                break
                ;;
            "Toggle_Automatic_Updates")
            	echo "NOT IMPLEMENTED YET"
                #break
                ;;
            "Other_Utilties")
                echo "$SCRIPT_MENU_TITLE_BARS"
                echo "$SCRIPT_NAME: UTILITY SELECTION"
                echo "$SCRIPT_MENU_TITLE_BARS"
                SCRIPT_UTILITIES_SETUP="true"
                profile_selection_ui
                #break
                ;;
            "Quit")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done

}

script_tmpfs_save_data_setup(){

    TMFS_ARGUMENTS="mode=1777,noatime,x-gvfs-hide,x-gdu-hide"

    mkdir -p "$SCRIPT_SAVED_DATA"

    if [ -e "$SCRIPT_SAVED_DATA" ]; then
            mount -t tmpfs -o "$TMFS_ARGUMENTS" tmpfs "$SCRIPT_SAVED_DATA"
    fi

}

#MAIN LOGIC STARTS HERE:

if [[ "$@" == "apply_optimizations" ]]; then

    #############################################################################
    #IMPORTANT: SCRIPT DIRS SETUP (OPTIMIZATIONS - MAIN/TMFPS SCRIPT ONLY)
    cd /var/lib/L_OP_DEV
    source ./utility_scripts/script_directories.sh
    source $SAVED_OPTIMIZATION_GOALS
    #############################################################################

    if [[ $SYSTEM_PORTABLE_INSTALL == "true" ]]; then
        #SAVE DATA ON TMPFS TO REDUCE DISK WRITES
        script_tmpfs_save_data_setup

        #REGENERATE ANALYSIS DATA
        script_system_hardware_analysis
        script_system_software_analysis

        if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" ]]; then
            source $SAVED_CPU_DATA
            source $SAVED_RAM_DATA
            source $SAVED_SWAP_STORAGE_DATA
            #IF BOOTLOADER ARGS NEED TO BE UPDATED, REBOOT COMPUTER ONCE (IT'S ONLY NEEDED FOR PORTABLE INSTALLS)
            if [[ "$SCANNED_CPU_CLASSIFICATION" != "$CPU_CLASS" || "$SCANNED_RAM_CLASSIFICATION" != "$RAM_CLASS" || "$SCANNED_SYSTEM_SWAP_PARTITION_DETECTED" != "$SYSTEM_SWAP_PARTITION_DETECTED" ]]; then
                #$BOOTLOADER_OPTIMIZATIONS
                echo ""
                #UPDATE OPTIMIZATION GOALS FILE WITH THE NEWLY SCANNED HARDWARE, OR ELSE IT WILL TRIGGER A REBOOT LOOP
                #profile_save_optimization_goals
                #reboot
            fi
	    fi
    fi

    script_system_hardware_optimizations
    script_system_software_optimizations

elif [[ "$@" == "apply_user_optimizations" ]]; then

    #############################################################################
    #IMPORTANT: SCRIPT DIRS SETUP (OPTIMIZATIONS - MAIN/TMFPS SCRIPT ONLY)
    cd /var/lib/L_OP_DEV
    source ./utility_scripts/script_directories.sh
    source $SAVED_OPTIMIZATION_GOALS
    #############################################################################

    if [[ $SYSTEM_PORTABLE_INSTALL == "true" ]]; then
        #REGENERATE ANALYSIS DATA
        script_system_user_software_analysis
    fi

    if [[ $SYSTEM_AUTOMATIC_UPDATES == "true" ]]; then
        $UPDATE_DISTRO
    fi

    script_system_user_software_optimizations

else

    ##################################################################
    #IMPORTANT: SCRIPT DIRS SETUP
    source ./utility_scripts/script_directories.sh
    ##################################################################

    chmod -R +x "$SCRIPT_MAIN_FOLDER"

    if [[ -e $SCRIPT_MAIN_FOLDER ]]; then
        SCRIPT_BEING_INSTALLED="false"
    else
        SCRIPT_BEING_INSTALLED="true"
        #RELOAD SCRIPT DIRECTORIES
        ./utility_scripts/script_directories.sh
    fi

    #SCRIPT MAIN ACTION
    script_main_menu

fi
