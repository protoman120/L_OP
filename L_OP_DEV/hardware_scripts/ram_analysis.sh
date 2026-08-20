#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
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

RAM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
RAM_B=$((RAM_KB * 1024))
RAM_MB=$((RAM_KB / 1024))
RAM_GB=$((RAM_KB / 1024 / 1024))
RAM_GB_PHYSICAL=$(($RAM_GB+1))
RAM_GENERATION="$( dmidecode -t memory | awk -F: '/Type: DDR/ {print $2; exit}' | xargs)"
RAM_SPEED="$( dmidecode -t memory | awk -F: '/Configured Memory Speed/ {print $2; exit}' | grep -o '[0-9]\+')"
ram_classification

cat > "$SAVED_RAM_DATA" <<EOF
    export RAM_KB=$(printf '%q' "$RAM_KB")
    export RAM_B=$(printf '%q' "$RAM_B")
    export RAM_MB=$(printf '%q' "$RAM_MB")
    export RAM_GB=$(printf '%q' "$RAM_GB")
    export RAM_GB_PHYSICAL=$(printf '%q' "$RAM_GB_PHYSICAL")
    export RAM_GENERATION=$(printf '%q' "$RAM_GENERATION")
    export RAM_SPEED=$(printf '%q' "$RAM_SPEED")
    export RAM_CLASS=$(printf '%q' $RAM_CLASS)
EOF
