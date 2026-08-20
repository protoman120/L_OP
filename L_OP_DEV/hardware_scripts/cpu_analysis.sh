#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

cpu_save_data(){

    cat > $SAVED_CPU_DATA <<EOF
    export CPU_PATH=$(printf '%q' "$CPU_PATH")
    export CPU_MODEL=$(printf '%q' "$CPU_MODEL")
    export CPU_VENDOR_ID=$(printf '%q' "$CPU_VENDOR_ID")
    export CPU_THREADS=$(printf '%q' "$CPU_THREADS")
    export CPU_MULTITHREADING_ENABLED=$(printf '%q' "$CPU_MULTITHREADING_ENABLED")
    export CPU_CORES=$(printf '%q' "$CPU_CORES")
    export CPU_MIN_FREQ=$(printf '%q' "$CPU_MIN_FREQ")
    export CPU_MIN_FREQ_HUMAN_READABLE_GHZ=$(printf '%q' "$CPU_MIN_FREQ_HUMAN_READABLE_GHZ")
    export CPU_MIN_FREQ_HUMAN_READABLE_MHZ=$(printf '%q' "$CPU_MIN_FREQ_HUMAN_READABLE_MHZ")
    export CPU_MAX_FREQ=$(printf '%q' "$CPU_MAX_FREQ")
    export CPU_MAX_FREQ_HUMAN_READABLE_GHZ=$(printf '%q' "$CPU_MAX_FREQ_HUMAN_READABLE_GHZ")
    export CPU_MAX_FREQ_HUMAN_READABLE_MHZ=$(printf '%q' "$CPU_MAX_FREQ_HUMAN_READABLE_MHZ")
    export CPU_L3_CACHE_SIZE=$(printf '%q' "$CPU_L3_CACHE_SIZE")
    export CPU_L3_CACHE_SIZE_MB=$(printf '%q' "$CPU_L3_CACHE_SIZE_MB")
    export CPU_L3_CACHE_SIZE_KB=$(printf '%q' "$CPU_L3_CACHE_SIZE_KB")
    export CPU_L2_CACHE_SIZE=$(printf '%q' "$CPU_L2_CACHE_SIZE")
    export CPU_L2_CACHE_SIZE_MB=$(printf '%q' "$CPU_L2_CACHE_SIZE_MB")
    export CPU_L2_CACHE_SIZE_KB=$(printf '%q' "$CPU_L2_CACHE_SIZE_KB")
    export CPU_L1D_CACHE_SIZE=$(printf '%q' "$CPU_L1D_CACHE_SIZE")
    export CPU_L1D_CACHE_SIZE_MB=$(printf '%q' "$CPU_L1D_CACHE_SIZE_MB")
    export CPU_L1D_CACHE_SIZE_KB=$(printf '%q' "$CPU_L1D_CACHE_SIZE_KB")
    export CPU_L1I_CACHE_SIZE=$(printf '%q' "$CPU_L1I_CACHE_SIZE")
    export CPU_L1I_CACHE_SIZE_MB=$(printf '%q' "$CPU_L1I_CACHE_SIZE_MB")
    export CPU_L1I_CACHE_SIZE_KB=$(printf '%q' "$CPU_L1I_CACHE_SIZE_KB")
    export CPU_CLASS=$(printf '%q' "$CPU_CLASS")
    export CURRENT_CPU_TDP_INTEL=$(printf '%q' "$CURRENT_CPU_TDP_INTEL")
    export CPU_CLASS=$(printf '%q' "$CPU_CLASS")

EOF

}

CPU_PATH="/sys/devices/system/cpu"

CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
CPU_VENDOR_ID=$(grep "vendor_id" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)

CPU_THREADS=$(nproc)
CPU_MULTITHREADING_ENABLED=$(lscpu | awk -F: '/Thread\(s\) per core/ {gsub(/ /,"",$2); print $2}')
CPU_CORES=$((CPU_THREADS/CPU_MULTITHREADING_ENABLED))

CPU_MIN_FREQ=$(cat $CPU_PATH/cpu0/cpufreq/cpuinfo_min_freq 2>/dev/null || echo 0)
CPU_MIN_FREQ_HUMAN_READABLE_GHZ=$(echo "scale=2; $CPU_MIN_FREQ/1000000" | bc -l)
CPU_MIN_FREQ_HUMAN_READABLE_MHZ=$(echo "scale=0; $CPU_MIN_FREQ/1000" | bc -l)

CPU_MAX_FREQ=$(cat $CPU_PATH/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo 0)
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

if (( CPU_THREADS <= 2  ||  CPU_MAX_FREQ <= 300000 )); then #VERY LOW CPU CLASS, MAX OF 3GHZ OR LOWER OR 4 THREADS OR LESS
    CPU_CLASS="verylow"
elif (( CPU_THREADS <= 4  ||  CPU_MAX_FREQ <= 3500000 )); then #LOW CPU CLASS, MAX 3.5GHZ AND 4 THREADS
    CPU_CLASS="low"
elif (( CPU_THREADS <= 8  ||  CPU_MAX_FREQ <= 4000000 )); then #MEDIUM CPU CLASS, MAX 4GHZ AND 6 THREADS
    CPU_CLASS="mid"
elif (( CPU_THREADS >= 8  ||  CPU_MAX_FREQ >= 4000000 )); then #HIGH CPU CLASS, AT LEAST 4.5GHZ AND 8 THREADS
    CPU_CLASS="high"
else
    echo "CPU_CLASS NOT SELECTED CORRECLY, APPLYING AUTO, MID-RANGE, PLEASE NOTIFY OF THIS ISSUE"
    CPU_CLASS="mid"
fi

cpu_save_data