#!/bin/bash

#L_OP MAIN SCRIPT

if [[ $EUID -ne 0 ]]; then
    echo "Root access required, please retry with sudo."
    exit 1
fi

SCRIPT_MENU_TITLE_BARS="###################################"

script_check_folder_name(){
    if [[ $SCRIPT_DEV_BRANCH == "DEV" ]]; then
        if [[ $SCRIPT_MAIN_FOLDER_NAME != $SCRIPT_NAME ]]; then
            cd $SCRIPT_MAIN_FOLDER
            cd ..
            mv ./$SCRIPT_MAIN_FOLDER_NAME ./$SCRIPT_NAME
            cd ./$SCRIPT_NAME
            #Updates current directory
            source ./utility_scripts/script_directories.sh
        fi
    else
        if [[ $SCRIPT_MAIN_FOLDER_NAME != $SCRIPT_NAME_RELEASE ]]; then
            cd $SCRIPT_MAIN_FOLDER
            cd ..
            mv ./$SCRIPT_MAIN_FOLDER_NAME ./$SCRIPT_NAME_RELEASE
            cd ./$SCRIPT_NAME_RELEASE
            #Updates current directory
            source ./utility_scripts/script_directories.sh
        fi
    fi
}

script_check_install_dir(){
    if [[ $SCRIPT_DEV_BRANCH == "DEV" ]]; then
        SCRIPT_INSTALL_DIR=$SCRIPT_INSTALLED_DIR
        TESTING_MODE="true"
    else
        SCRIPT_INSTALL_DIR=$SCRIPT_INSTALLED_DIR_RELEASE
        TESTING_MODE="false"
    fi
}

script_clear_screen(){
    if [[ "$TESTING_MODE" == "false" ]]; then
        clear
    fi
}

script_system_hardware_analysis(){
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME: CPU ANALYSIS"
    echo "$SCRIPT_MENU_TITLE_BARS"
    $CPU_ANALYSIS
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME: GPU ANALYSIS"
    echo "$SCRIPT_MENU_TITLE_BARS"
	$GPU_ANALYSIS
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME: RAM ANALYSIS"
    echo "$SCRIPT_MENU_TITLE_BARS"
	$RAM_ANALYSIS
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME: STORAGE ANALYSIS"
    echo "$SCRIPT_MENU_TITLE_BARS"
	$STORAGE_ANALYSIS
}

script_system_software_analysis(){
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME: OS ANALYSIS"
    echo "$SCRIPT_MENU_TITLE_BARS"
    $OS_ANALYSIS
}

script_system_user_software_analysis(){
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME: DE ANALYSIS"
    echo "$SCRIPT_MENU_TITLE_BARS"
    $DE_ANALYSIS
}

script_system_hardware_optimizations(){

    if [[ $OPTIMIZATION_CPU_ENABLED == "enabled" ]]; then
        echo "$SCRIPT_MENU_TITLE_BARS"
        echo "$SCRIPT_NAME: CPU OPTIMIZATIONS"
        echo "$SCRIPT_MENU_TITLE_BARS"
        $CPU_OPTIMIZATIONS
    fi

    if [[ $OPTIMIZATION_GPU_ENABLED == "enabled" ]]; then
        echo "$SCRIPT_MENU_TITLE_BARS"
        echo "$SCRIPT_NAME: GPU OPTIMIZATIONS"
        echo "$SCRIPT_MENU_TITLE_BARS"
        $GPU_OPTIMIZATIONS
    fi
    
    if [[ $OPTIMIZATION_RAM_ENABLED == "enabled" ]]; then
        echo "$SCRIPT_MENU_TITLE_BARS"
        echo "$SCRIPT_NAME: RAM OPTIMIZATIONS"
        echo "$SCRIPT_MENU_TITLE_BARS"
        $RAM_OPTIMIZATIONS
    fi

    if [[ $OPTIMIZATION_STORAGE_ENABLED == "enabled" ]]; then
        echo "$SCRIPT_MENU_TITLE_BARS"
        echo "$SCRIPT_NAME: STORAGE OPTIMIZATIONS"
        echo "$SCRIPT_MENU_TITLE_BARS"
        $STORAGE_OPTIMIZATIONS
        $STORAGE_ANALYSIS
    fi

}

script_system_software_optimizations(){
    
    echo "Starting software optimizations:"
    echo "TMPFS: $OPTIMIZATION_TMPFS_CACHING_ENABLED"

    if [[ $OPTIMIZATION_OS_ENABLED == "enabled" ]]; then
        $KERNEL_OPTIMIZATIONS
    fi
    
    if [[ $OPTIMIZATION_NETWORK_ENABLED == "enabled" ]]; then
        $NETWORK_OPTIMIZATIONS
    fi

    if [[ $OPTIMIZATION_TMPFS_CACHING_ENABLED == "enabled" ]]; then
        $TMPFS_CACHING_SETUP
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
}

profile_save_optimization_goals() {

    cat > "$SAVED_OPTIMIZATION_GOALS" <<EOF
        #SYSTEM USER

        export SYSTEM_USER=$(printf '%q' "$SYSTEM_USER")
        export SYSTEM_SETUP_USER=$(printf '%q' "$SYSTEM_SETUP_USER")

        SYSTEM_PORTABLE_INSTALL=$(printf '%q' "$SYSTEM_PORTABLE_INSTALL")

        #SCANNED HARDWARE (USED TO DETECT HARDWARE CHANGES ON PORTABLE INSTALLS):
        
        #ROOT STORAGE:
        STORAGE_ROOT_DEVICE_TYPE=$(printf '%q' "$STORAGE_ROOT_DEVICE_TYPE")
        #SWAP:
        SCANNED_SYSTEM_SWAP_PARTITION_DETECTED=$(printf '%q' "$SYSTEM_SWAP_PARTITION_DETECTED")
        #CPU:
        SCANNED_CPU_VENDOR_ID=$(printf '%q' "$SCANNED_CPU_VENDOR_ID")
        SCANNED_CPU_CLASSIFICATION=$(printf '%q' "$CPU_CLASS")
        #RAM:
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
        OPTIMIZATION_DE_ENABLED=$(printf '%q' "$OPTIMIZATION_DE_ENABLED")
        OPTIMIZATION_BOOTLOADER_ENABLED=$(printf '%q' "$OPTIMIZATION_BOOTLOADER_ENABLED")

        #USER_SETTINGS:
        ADDITIONAL_CPU_COOLING=$(printf '%q' "$ADDITIONAL_CPU_COOLING")
        ADDITIONAL_GPU_COOLING=$(printf '%q' "$ADDITIONAL_GPU_COOLING")
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
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "SELECTED OPTION: $(basename "$SELECTED_PROFILE")"
    echo "$SCRIPT_MENU_TITLE_BARS"

    if [[ $BASIC_INSTALL_SCRIPT != "true" && $SCRIPT_UTILITIES_SETUP != "true" ]]; then
        if (( $PROFILE_SELECTION == $FILECOUNTER )); then
            BASIC_INSTALL_SCRIPT="true"
            script_clear_screen
            profile_selection_ui
        else
            source $SELECTED_PROFILE
        fi
    elif [[ $BASIC_INSTALL_SCRIPT == "true" && $SCRIPT_UTILITIES_SETUP != "true" ]]; then
        if (( $PROFILE_SELECTION == $FILECOUNTER )); then
            BASIC_INSTALL_SCRIPT="false"
            script_clear_screen
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

    if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" ]]; then
        $BOOTLOADER_REMOVE_OPTIMIZATIONS
    fi
    $SCRIPT_REMOVE_SERVICES
    $TMPFS_CACHING_SERVICES_REMOVAL
    $SCRIPT_TERMINAL_COMMANDS_REMOVAL
    rm -r $SCRIPT_SAVED_DATA
    rm -r $SCRIPT_INSTALL_DIR

    if [[ $INSTALLING_SCRIPT != "true" ]]; then
        ask_system_reboot
    fi

}

install_script(){

    #USER SETTINGS VARIABLES SETUP
    ADDITIONAL_CPU_COOLING="disabled"
    ADDITIONAL_GPU_COOLING="disabled"

	#PROFILE SELECTION
	profile_selection_ui
    #profile_selection_simple

    if [ -e $SCRIPT_INSTALL_DIR ]; then
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

    source $SAVED_CPU_DATA
    source $SAVED_RAM_DATA

    #DISABLES FUNCTIONALITY THAT NEEDS A REWORK
    if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" ]]; then
        OPTIMIZATION_BOOTLOADER_ENABLED="disabled_until_reworked"
    fi
    if [[ $OPTIMIZATION_DE_ENABLED == "enabled" ]]; then
        OPTIMIZATION_DE_ENABLED="disabled_until_reworked"
    fi

    #THIS IS HERE BECOUSE THIS FILE INCLUDES THE SELECTION FOR PORTABLE INSTALL
    profile_save_optimization_goals

    cp -r $SCRIPT_MAIN_FOLDER $SCRIPT_INSTALL_DIR

    #SERVICES SETUP
    $SCRIPT_SETUP_SERVICES
    $TMPFS_CACHING_SERVICES_SETUP
    $SCRIPT_TERMINAL_COMMANDS_SETUP

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
    script_clear_screen
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME"
    echo "$SCRIPT_MENU_TITLE_BARS"

    echo ""
    echo "Available Options:"
    PS3='Choose an option: '
    options=("Install" "Uninstall" "Change_Profile" "Profile_Settings" "Other_Utilties" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Install")
                if [[ -e $SCRIPT_INSTALL_DIR || -e $SCRIPT_L_OP_SERVICE || -e $SCRIPT_L_OP_USER_SERVICE ]]; then
                    echo "L_OP ALREADY INSTALLED, UNINSTALL FIRST BEFORE REINSTALLING"
                else
                    script_clear_screen
                    INSTALLING_SCRIPT="true"
                    echo "$SCRIPT_MENU_TITLE_BARS"
                    echo "$SCRIPT_NAME: PROFILE SELECTION"
                    echo "$SCRIPT_MENU_TITLE_BARS"
                    INSTALL_SCRIPT="true"
                    install_script
                fi
                break
                ;;
            "Uninstall")
                if [[ -e $SCRIPT_INSTALL_DIR || -e $SCRIPT_L_OP_SERVICE || -e $SCRIPT_L_OP_USER_SERVICE ]]; then
                    script_clear_screen
                    echo "$SCRIPT_MENU_TITLE_BARS"
                    echo "$SCRIPT_NAME: UNINSTALLING"
                    echo "$SCRIPT_MENU_TITLE_BARS"
				    uninstall_script
                    echo "L_OP UNINSTALLED"
                else
                    echo "L_OP NOT INSTALLED"
                    return 0
                fi
				break
                ;;
            "Change_Profile")
                if [[ -e $SCRIPT_INSTALL_DIR && -e $SCRIPT_L_OP_SERVICE && -e $SCRIPT_L_OP_USER_SERVICE ]]; then
                    cd $SCRIPT_INSTALL_DIR
                    source ./utility_scripts/script_directories.sh
                    source $SAVED_OPTIMIZATION_GOALS
                    script_clear_screen
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
                    echo "L_OP NOT INSTALLED, CANNOT CHANGE PROFILE, PLEASE INSTALL FIRST"
                    return 0
                fi
                break
                ;;
            "Profile_Settings")
                cd $SCRIPT_INSTALL_DIR
                source ./utility_scripts/script_directories.sh
                source $SAVED_OPTIMIZATION_GOALS
                script_clear_screen
                if [[ -e $SCRIPT_INSTALL_DIR && -e $SCRIPT_L_OP_SERVICE && -e $SCRIPT_L_OP_USER_SERVICE ]]; then
                    script_profile_settings
                    profile_save_optimization_goals
                    ask_system_reboot
                else
                    echo "L_OP NOT INSTALLED, CANNOT CHANGE PROFILE SETTINGS, PLEASE INSTALL FIRST"
                    return 0
                fi
                break
                ;;
            "Other_Utilties")
                script_clear_screen
                echo "$SCRIPT_MENU_TITLE_BARS"
                echo "$SCRIPT_NAME: UTILITY SELECTION"
                echo "$SCRIPT_MENU_TITLE_BARS"
                SCRIPT_UTILITIES_SETUP="true"
                profile_selection_ui
                break
                ;;
            "Quit")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done

}

script_profile_settings(){
    script_clear_screen
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME SETTINGS"
    echo ""
    echo "Current Settings:"
    echo "CPU_COOLING: $CPU_COOLING_OPTIMIZATION"
    echo "GPU_COOLING: $GPU_COOLING_OPTIMIZATION"
    echo "ADDITIONAL_CPU_COOLING: $ADDITIONAL_CPU_COOLING"
    echo "ADDITIONAL_GPU_COOLING: $ADDITIONAL_GPU_COOLING"
    echo "TMPFS_CACHING: $OPTIMIZATION_TMPFS_CACHING_ENABLED"
    echo "$SCRIPT_MENU_TITLE_BARS"
    echo ""
    echo "Available options to toggle:"
    PS3='Choose an option: '
    options=("CPU_COOLING" "GPU_COOLING" "ADDITIONAL_CPU_COOLING" "ADDITIONAL_GPU_COOLING" "TMPFS_CACHING" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "CPU_COOLING")
                if [[ $CPU_COOLING_OPTIMIZATION == "enabled" ]]; then
                    CPU_COOLING_OPTIMIZATION="disabled"
                else
                    CPU_COOLING_OPTIMIZATION="enabled"
                fi
                script_profile_settings
                break
                ;;
            "GPU_COOLING")
                if [[ $ADDITIONAL_CPU_COOLING == "enabled" ]]; then
                    ADDITIONAL_CPU_COOLING="disabled"
                else
                    ADDITIONAL_CPU_COOLING="enabled"
                fi
                script_profile_settings
				break
                ;;
            "ADDITIONAL_CPU_COOLING")
                if [[ $ADDITIONAL_CPU_COOLING == "enabled" ]]; then
                    ADDITIONAL_CPU_COOLING="disabled"
                else
                    ADDITIONAL_CPU_COOLING="enabled"
                fi
                script_profile_settings
                break
                ;;
            "ADDITIONAL_GPU_COOLING")
                if [[ $ADDITIONAL_GPU_COOLING == "enabled" ]]; then
                    ADDITIONAL_GPU_COOLING="disabled"
                else
                    ADDITIONAL_GPU_COOLING="enabled"
                fi
                script_profile_settings
				break
                ;;
            "TMPFS_CACHING")
                if [[ $OPTIMIZATION_TMPFS_CACHING_ENABLED == "enabled" ]]; then
                    OPTIMIZATION_TMPFS_CACHING_ENABLED="disabled"
                else
                    OPTIMIZATION_TMPFS_CACHING_ENABLED="enabled"
                fi
                script_profile_settings
				break
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
            #source $SAVED_CPU_DATA
            #source $SAVED_RAM_DATA
            #source $SAVED_SWAP_STORAGE_DATA
            echo ""
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
    source ./utility_scripts/script_directories.sh
    source $SAVED_OPTIMIZATION_GOALS
    #############################################################################

    #if [[ $SYSTEM_PORTABLE_INSTALL == "true" ]]; then
        #REGENERATE ANALYSIS DATA
        #script_system_user_software_analysis
    #fi

    script_system_user_software_optimizations

else

    ##################################################################
    #IMPORTANT: SCRIPT DIRS SETUP
    source ./utility_scripts/script_directories.sh
    ##################################################################

    script_check_folder_name
    script_check_install_dir
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
