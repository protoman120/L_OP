#!/bin/bash

#L_OP MAIN SCRIPT

script_system_hardware_analysis(){
    $CPU_ANALYSIS
	$GPU_ANALYSIS
	$RAM_ANALYSIS
	$STORAGE_ANALYSIS
}

script_system_software_analysis(){
    $DE_ANALYSIS
    $OS_ANALYSIS
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

    if [[ $OPTIMIZATION_DE_ENABLED == "enabled" ]]; then
        $DE_OPTIMIZATIONS
    fi

    if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" ]]; then
        $BOOTLOADER_OPTIMIZATIONS
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
    
    if [[ "$TESTING_MODE" == "true" ]];then
         echo ""
         echo "${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}"
         echo "WARNING: TESTING MODE ENABLED, OPTIMIZATIONS SELECTED WILL NOT BE APPLIED"
         echo "PC ANALYSIS DATA WILL BE SAVED ON /home/${SYSTEM_USER}"
         echo "${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}${MENU_SPACING}"
    fi
}

profile_selection() {

    PROFILE=""
    PROFILE_AMOUNT=0
    echo "TESTING: $SCRIPT_PROFILES"

    for PROFILE in $SCRIPT_PROFILES/*; do
        echo "TESTING PROFILE_FILE: $SCRIPT_PROFILES"
        if [ e- $PROFILE ]; then
            $PROFILE_NAME=$PROFILE
            $PROFILE_AMOUNT=$($PROFILE_AMOUNT + 1)
            echo "$PROFILE_AMOUNT ) $PROFILE_NAME"
        fi
    done

    SELECTED_PROFILE=10000000
    while (( $SELECTED_PROFILE > PROFILE_AMOUNT)); do
        read -rp "Choose a profile: " SELECTED_PROFILE
    done

    PROFILE_COUNT=0
    for PROFILE in $SCRIPT_PROFILES/*; do
        if [ e- $SCRIPT_PROFILES/$PROFILE ]; then
            PROFILE_COUNT=$($PROFILE_COUNT + 1)
            if $(($PROFILE_COUNT == $SELECTED_PROFILE)); then
                SELECTED_PROFILE="$PROFILE"
            fi
        fi
    done

    if [ e- $PROFILE != "" ]; then
        PROFILE_SELECTED="true"
        echo "SELECTED PROFILE: $SELECTED_PROFILE"
    fi

}

profile_save_optimization_goals() {

    cat > "$SAVED_OPTIMIZATION_GOALS" <<EOF
        #SYSTEM USER

        SYSTEM_USER=$(printf '%q' "$SYSTEM_USER")
        SYSTEM_SETUP_USER=$(printf '%q' "$SYSTEM_SETUP_USER")

        SYSTEM_AUTOMATIC_UPDATES=$(printf '%q' "$SYSTEM_AUTOMATIC_UPDATES")
        SYSTEM_PORTABLE_INSTALL=$(printf '%q' "$SYSTEM_PORTABLE_INSTALL")

        #SCANNED HARDWARE (TO USE AS REFERENCE FOR PORTABLE INSTALLS)
        
        STORAGE_ROOT_DEVICE_TYPE=$(printf '%q' "$STORAGE_ROOT_DEVICE_TYPE")
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

profile_selection_simple() {
    #TEMP FUNCTION UNTIL I GET THE OTHER WORKING
    echo "Available Options:"
    PS3='Choose a profile: '
    options=("desktop" "gaming" "gaming_high_performance" "mc_server_self_hosting" "latency" "throughput" "custom_profile" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "desktop")
                source $SCRIPT_PROFILES/desktop.sh
                break
                ;;
            "gaming")
				source $SCRIPT_PROFILES/gaming.sh
				break
                ;;
            "gaming_high_performance")
                source $SCRIPT_PROFILES/gaming_high_performance.sh
                break
                ;;
            "mc_server_self_hosting")
                source $SCRIPT_PROFILES/mc_server_self_hosting.sh
                break
                ;;
            "latency")
                source $SCRIPT_PROFILES/latency.sh
                break
                ;;
            "throughput")
                source $SCRIPT_PROFILES/throughput.sh
                break
                ;;
            "custom_profile")
                read -rp "Enter profile name: " custom_profile_name
                if [ -e $SCRIPT_PROFILES/custom_profile_name.sh ]; then
                    source $SCRIPT_PROFILES/custom_profile_name.sh
                    break
                else
                    echo "$SCRIPT_PROFILES/custom_profile_name.sh: File not found"
                fi
                ;;    
            "Quit")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done

    echo "Selected profile: $opt"

}

uninstall_script(){
    rm -r $SCRIPT_INSTALLED_DIR
    $BOOTLOADER_REMOVE_OPTIMIZATIONS
}

install_script(){

	#PROFILE SELECTION
	#profile_selection
    profile_selection_simple

	#HARDWARE SCANNING:
	$CPU_ANALYSIS
	$GPU_ANALYSIS
	$RAM_ANALYSIS
	$STORAGE_ANALYSIS
    $DE_ANALYSIS
    $OS_ANALYSIS

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

    #THIS IS HERE BECOUSE THIS FILE INCLUDES THE SELECTION FOR PORTABLE INSTALL AND AUTO UPDATES
    profile_save_optimization_goals

    #SERVICES SETUP
    $SCRIPT_SETUP_SERVICES
    $TMPFS_CACHING_SERVICES_SETUP

    if [ -e $SCRIPT_INSTALLED_DIR ]; then
        echo "L_OP ALREADY INSTALLED, REINSTALLING"
        rm -r $SCRIPT_INSTALLED_DIR
        cp -r $SCRIPT_MAIN_FOLDER $SCRIPT_INSTALLED_DIR
    else
        cp -r $SCRIPT_MAIN_FOLDER $SCRIPT_INSTALLED_DIR
    fi

    #HAS TO BE APPLIED HERE SO IT'S APPLIED ON REBOOT
    if [[ $OPTIMIZATION_BOOTLOADER_ENABLED == "enabled" ]]; then
        $BOOTLOADER_OPTIMIZATIONS
    fi

    if [[ $SYSTEM_PORTABLE_INSTALL == "true" ]]; then
        #THIS DATA WILL BE REGENERATED ON REBOOT
        rm -r $SCRIPT_INSTALLED_DIR/saved_data
    fi

	echo "Please restart your PC to apply"

}

script_main_menu(){

	SCRIPT_MENU_TITLE_BARS="###################################"

    echo "$SCRIPT_MENU_TITLE_BARS"
    echo "$SCRIPT_NAME"
    echo "$SCRIPT_MENU_TITLE_BARS"

    echo ""
    echo "Available Options:"
    PS3='Choose an option: '
    options=("Install" "Uninstall" "Change_Profile" "Toggle_Automatic_Updates" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Install")
                install_script
                break
                ;;
            "Uninstall")
                if [ -e $SCRIPT_INSTALLED_DIR ]; then
				    uninstall_script
                    echo "L_OP UNINSTALLED"
                else
                    echo "L_OP NOT INSTALLED"
                fi
				break
                ;;
            "Change_Profile")
                profile_selection
                break
                ;;
            "Toggle_Automatic_Updates")
            	echo "NOT IMPLEMENTED YET"
                #break
                ;;
            "Toggle_Automatic_Updates")
                echo "NOT IMPLEMENTED YET"
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

chmod -R +x $SCRIPT_MAIN_FOLDER

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
    fi

    script_system_hardware_optimizations
    script_system_software_optimizations

    if [[ $SYSTEM_AUTOMATIC_UPDATES == "true" ]]; then
        echo ""
    fi

else

    ##################################################################
    #IMPORTANT: SCRIPT DIRS SETUP
    source ./utility_scripts/script_directories.sh
    ##################################################################

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





