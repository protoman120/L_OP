#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
if [ -e $SAVED_OPTIMIZATION_GOALS ]; then
    source $SAVED_OPTIMIZATION_GOALS
fi
##################################################################

ram_classification(){
	if (( RAM_GB_PHYSICAL < 4 || RAM_GB_PHYSICAL == 4 )); then
		RAM_CLASS="verylow"
	elif (( (( RAM_GB_PHYSICAL > 4 && RAM_GB_PHYSICAL < 8 )) || RAM_GB_PHYSICAL == 8 )); then
		RAM_CLASS="low"
	elif (( (( RAM_GB_PHYSICAL > 8 && RAM_GB_PHYSICAL < 16 )) || RAM_GB_PHYSICAL == 16 )); then
		RAM_CLASS="mid"
	elif (( (( RAM_GB_PHYSICAL > 16 && RAM_GB_PHYSICAL < 32 )) || RAM_GB_PHYSICAL == 32 )); then
		RAM_CLASS="high"
	elif (( RAM_GB_PHYSICAL > 32 )); then
		RAM_CLASS="veryhigh"
	fi
}

ram_essential_scan(){
	RAM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
	RAM_GB=$((RAM_KB / 1024 / 1024))
	RAM_GB_PHYSICAL=$(($RAM_GB+1))
	ram_classification
}

ram_full_scan(){
	RAM_B=$((RAM_KB * 1024))
	RAM_MB=$((RAM_KB / 1024))
	RAM_GENERATION="$( dmidecode -t memory | awk -F: '/Type: DDR/ {print $2; exit}' | xargs)"
	RAM_SPEED="$( dmidecode -t memory | awk -F: '/Configured Memory Speed/ {print $2; exit}' | grep -o '[0-9]\+')"
}

ram_save_data(){
	cat > "$SAVED_RAM_DATA" <<EOF
		RAM_KB=$(printf '%q' "$RAM_KB")
		RAM_B=$(printf '%q' "$RAM_B")
		RAM_MB=$(printf '%q' "$RAM_MB")
		RAM_GB=$(printf '%q' "$RAM_GB")
		RAM_GB_PHYSICAL=$(printf '%q' "$RAM_GB_PHYSICAL")
		RAM_GENERATION=$(printf '%q' "$RAM_GENERATION")
		RAM_SPEED=$(printf '%q' "$RAM_SPEED")
		RAM_CLASS=$(printf '%q' $RAM_CLASS)
EOF
}

ram_basic_scan(){
    ram_essential_scan
    ram_classification
    #Does not save data, used for portable installs to check RAM changes
}

ram_complete_scan(){
    ram_essential_scan
    ram_classification
    ram_full_scan
    ram_save_data
}

if [[ "$@" == "ram_basic_scan" ]]; then
    ram_basic_scan
elif [[ "$@" == "ram_complete_scan" ]]; then
    ram_complete_scan
else
    if [[ $SYSTEM_PORTABLE_INSTALL == "true" ]]; then
        ram_basic_scan
        if [[ $SCANNED_RAM_CLASSIFICATION != "RAM_CLASS" ]]; then
            ram_complete_scan
        fi
    else
        ram_complete_scan
    fi
fi