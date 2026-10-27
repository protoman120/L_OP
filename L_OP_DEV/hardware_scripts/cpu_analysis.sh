#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
if [ -e $SAVED_OPTIMIZATION_GOALS ]; then
    source $SAVED_OPTIMIZATION_GOALS
fi
##################################################################

cpu_save_data(){
    cat > $SAVED_CPU_DATA <<EOF
        CPU_PATH=$(printf '%q' "$CPU_PATH")
        CPU_MODEL=$(printf '%q' "$CPU_MODEL")
        CPU_VENDOR_ID=$(printf '%q' "$CPU_VENDOR_ID")
        #CPU CORES/THREADS:
        CPU_THREADS=$(printf '%q' "$CPU_THREADS")
        CPU_MULTITHREADING_ENABLED=$(printf '%q' "$CPU_MULTITHREADING_ENABLED")
        CPU_CORES=$(printf '%q' "$CPU_CORES")
        CPU_MULTITHREADING_ACTIVE=$(printf '%q' "$CPU_MULTITHREADING_ACTIVE")
        #CPU FREQUENCY:
        CPU_MIN_FREQ=$(printf '%q' "$CPU_MIN_FREQ")
        CPU_MIN_FREQ_HUMAN_READABLE_GHZ=$(printf '%q' "$CPU_MIN_FREQ_HUMAN_READABLE_GHZ")
        CPU_MIN_FREQ_HUMAN_READABLE_MHZ=$(printf '%q' "$CPU_MIN_FREQ_HUMAN_READABLE_MHZ")
        CPU_MAX_FREQ=$(printf '%q' "$CPU_MAX_FREQ")
        CPU_MAX_FREQ_HUMAN_READABLE_GHZ=$(printf '%q' "$CPU_MAX_FREQ_HUMAN_READABLE_GHZ")
        CPU_MAX_FREQ_HUMAN_READABLE_MHZ=$(printf '%q' "$CPU_MAX_FREQ_HUMAN_READABLE_MHZ")
        #CPU CACHES:
        CPU_L3_CACHE_SIZE=$(printf '%q' "$CPU_L3_CACHE_SIZE")
        CPU_L3_CACHE_SIZE_MB=$(printf '%q' "$CPU_L3_CACHE_SIZE_MB")
        CPU_L3_CACHE_SIZE_KB=$(printf '%q' "$CPU_L3_CACHE_SIZE_KB")
        CPU_L2_CACHE_SIZE=$(printf '%q' "$CPU_L2_CACHE_SIZE")
        CPU_L2_CACHE_SIZE_MB=$(printf '%q' "$CPU_L2_CACHE_SIZE_MB")
        CPU_L2_CACHE_SIZE_KB=$(printf '%q' "$CPU_L2_CACHE_SIZE_KB")
        CPU_L1D_CACHE_SIZE=$(printf '%q' "$CPU_L1D_CACHE_SIZE")
        CPU_L1D_CACHE_SIZE_MB=$(printf '%q' "$CPU_L1D_CACHE_SIZE_MB")
        CPU_L1D_CACHE_SIZE_KB=$(printf '%q' "$CPU_L1D_CACHE_SIZE_KB")
        CPU_L1I_CACHE_SIZE=$(printf '%q' "$CPU_L1I_CACHE_SIZE")
        CPU_L1I_CACHE_SIZE_MB=$(printf '%q' "$CPU_L1I_CACHE_SIZE_MB")
        CPU_L1I_CACHE_SIZE_KB=$(printf '%q' "$CPU_L1I_CACHE_SIZE_KB")
        #CPU CLASSIFICATION:
        CPU_CLASS=$(printf '%q' "$CPU_CLASS")
        #INTEL ONLY:
        CURRENT_CPU_TDP_INTEL=$(printf '%q' "$CURRENT_CPU_TDP_INTEL")

EOF
}

CPU_PATH="/sys/devices/system/cpu"

cpu_essential_scan(){
    CPU_VENDOR_ID=$(grep "vendor_id" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    CPU_THREADS=$(nproc)
    CPU_MULTITHREADING_ENABLED=$(lscpu | awk -F: '/Thread\(s\) per core/ {gsub(/ /,"",$2); print $2}')
    CPU_CORES=$((CPU_THREADS/CPU_MULTITHREADING_ENABLED))
    if (( CPU_MULTITHREADING_ENABLED >= 2 )); then
        CPU_MULTITHREADING_ACTIVE="true"
    else
        CPU_MULTITHREADING_ACTIVE="false"
    fi
    CPU_MAX_FREQ=$(cat $CPU_PATH/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo 0)
}

cpu_full_scan(){
    #NOTE: BEFORE USING THIS YOU'LL WANT TO USE "cpu_essential_scan" AND "cpu_classification" FIRST
    CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)

    CPU_MIN_FREQ=$(cat $CPU_PATH/cpu0/cpufreq/cpuinfo_min_freq 2>/dev/null || echo 0)
    CPU_MIN_FREQ_HUMAN_READABLE_GHZ=$(echo "scale=2; $CPU_MIN_FREQ/1000000" | bc -l)
    CPU_MIN_FREQ_HUMAN_READABLE_MHZ=$(echo "scale=0; $CPU_MIN_FREQ/1000" | bc -l)

    CPU_MAX_FREQ_HUMAN_READABLE_GHZ=$(echo "scale=2; $CPU_MAX_FREQ/1000000" | bc -l)
    CPU_MAX_FREQ_HUMAN_READABLE_MHZ=$(echo "scale=0; $CPU_MAX_FREQ/1000" | bc -l)

    CPU_L3_CACHE_SIZE=$(lscpu | awk -F: '/L3 cache/ {gsub(/^[ \t]+|[ \t]+$/,"",$2); split($2,a," "); if(a[2]=="MiB") print a[1]*1024*1024; else if(a[2]=="KiB") print a[1]*1024}')
    CPU_L3_CACHE_SIZE_MB=$(echo "scale=2; $CPU_L3_CACHE_SIZE/1024/1024" | bc)
    CPU_L3_CACHE_SIZE_KB=$(( CPU_L3_CACHE_SIZE / 1024 ))

    CPU_L2_CACHE_SIZE=$(lscpu | awk -F: '/L2 cache/ {gsub(/^[ \t]+|[ \t]+$/,"",$2); split($2,a," "); if(a[2]=="MiB") print a[1]*1024*1024; else if(a[2]=="KiB") print a[1]*1024}')
    CPU_L2_CACHE_SIZE_MB=$(echo "scale=2; $CPU_L2_CACHE_SIZE/1024/1024" | bc)
    CPU_L2_CACHE_SIZE_KB=$(($CPU_L2_CACHE_SIZE / 1024))

    #L1 Data Cache
    CPU_L1D_CACHE_SIZE=$(lscpu | awk -F: '/L1d cache/ {gsub(/^[ \t]+|[ \t]+$/,"",$2); split($2,a," "); if(a[2]=="KiB") print a[1]*1024}')
    CPU_L1D_CACHE_SIZE_MB=$(echo "scale=2; $CPU_L1D_CACHE_SIZE/1024/1024" | bc)
    CPU_L1D_CACHE_SIZE_KB=$(($CPU_L1D_CACHE_SIZE / 1024))

    #L1 Instruction Cache
    CPU_L1I_CACHE_SIZE=$(lscpu | awk -F: '/L1i cache/ {gsub(/^[ \t]+|[ \t]+$/,"",$2); split($2,a," "); if(a[2]=="KiB") print a[1]*1024}')
    CPU_L1I_CACHE_SIZE_MB=$(echo "scale=2; $CPU_L1I_CACHE_SIZE/1024/1024" | bc)
    CPU_L1I_CACHE_SIZE_KB=$(($CPU_L1I_CACHE_SIZE / 1024))

    if [[ "$CPU_VENDOR_ID" == "GenuineIntel" ]]; then
        CURRENT_CPU_TDP_INTEL=$(cat /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw)
        CURRENT_CPU_TDP_INTEL_HUMAN_READABLE=$(($CURRENT_CPU_TDP_INTEL/1000000))
    fi
}

cpu_classification(){
    if (( CPU_MAX_FREQ <= 300000 || CPU_CORES <= 2 )); then #VERY LOW CPU CLASS, MAX OF 3GHZ OR LOWER OR 4 CORES OR LESS
        CPU_CLASS="verylow"
    elif (( CPU_MAX_FREQ <= 3500000 || CPU_CORES <= 4 )); then #LOW CPU CLASS, MAX 3.5GHZ OR 4 CORES
        CPU_CLASS="low"
    elif (( CPU_MAX_FREQ <= 4000000 || CPU_CORES <= 6 )); then #MEDIUM CPU CLASS, MAX 4GHZ OR 6 CORES
        CPU_CLASS="mid"
    elif (( CPU_MAX_FREQ >= 4000000 || CPU_CORES >= 6 )); then #HIGH CPU CLASS, AT LEAST 4.5GHZ OR MORE THAN 6 CORES
        CPU_CLASS="high"
    else
        echo "CPU_CLASS NOT SELECTED CORRECLY, APPLYING AUTO, MID-RANGE, PLEASE NOTIFY OF THIS ISSUE"
        CPU_CLASS="mid"
    fi
}

cpu_basic_scan(){
    cpu_essential_scan
    cpu_classification
    #Does not save data, used for portable installs to check CPU changes
}

cpu_complete_scan(){
    cpu_essential_scan
    cpu_classification
    cpu_full_scan
    cpu_save_data
}

if [[ "$@" == "cpu_basic_scan" ]]; then
    cpu_basic_scan
elif [[ "$@" == "cpu_complete_scan" ]]; then
    cpu_complete_scan
else
    if [[ $SYSTEM_PORTABLE_INSTALL == "true" ]]; then
        cpu_basic_scan
        if [[ $SCANNED_CPU_VENDOR_ID != "CPU_VENDOR_ID" || $SCANNED_CPU_CLASSIFICATION != "CPU_CLASS" ]]; then
            cpu_complete_scan
        fi
    else
        cpu_complete_scan
    fi
fi