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
##################################################################

#Network cache buffers

if [[ $RAM_CLASS == "verylow" ]]; then
    echo 1048576 |  tee /proc/sys/net/core/rmem_default
    echo 2097152 |  tee /proc/sys/net/core/rmem_max
    echo 1048576 |  tee /proc/sys/net/core/wmem_default
    echo 2097152 |  tee /proc/sys/net/core/wmem_max
    echo 4096 |  tee /proc/sys/net/core/wmem_max
elif [[ $RAM_CLASS == "low" ]]; then
    echo 2097152 |  tee /proc/sys/net/core/rmem_default
    echo 4194304 |  tee /proc/sys/net/core/rmem_max
    echo 2097152 |  tee /proc/sys/net/core/wmem_default
    echo 4194304 |  tee /proc/sys/net/core/wmem_max
    echo 8192 |  tee /proc/sys/net/core/wmem_max
elif [[ $RAM_CLASS == "mid" ]]; then
    echo 4194304 |  tee /proc/sys/net/core/rmem_default
    echo 8388608 |  tee /proc/sys/net/core/rmem_max
    echo 4194304 |  tee /proc/sys/net/core/wmem_default
    echo 8388608 |  tee /proc/sys/net/core/wmem_max
    echo 16384 |  tee /proc/sys/net/core/wmem_max
elif [[ $RAM_CLASS == "high" ]]; then
    echo 8388608 |  tee /proc/sys/net/core/rmem_default
    echo 16777216 |  tee /proc/sys/net/core/rmem_max
    echo 8388608 |  tee /proc/sys/net/core/wmem_default
    echo 16777216 |  tee /proc/sys/net/core/wmem_max
    echo 32768 |  tee /proc/sys/net/core/wmem_max
elif [[ $RAM_CLASS == "veryhigh" ]]; then
    echo 16777216 |  tee /proc/sys/net/core/rmem_default
    echo 33554432 |  tee /proc/sys/net/core/rmem_max
    echo 16777216 |  tee /proc/sys/net/core/wmem_default
    echo 33554432 |  tee /proc/sys/net/core/wmem_max
    echo 65536 |  tee /proc/sys/net/core/wmem_max
fi

echo "4096 65536 8388608" |  tee /proc/sys/net/ipv4/tcp_rmem
echo "4096 65536 8388608" |  tee /proc/sys/net/ipv4/tcp_wmem


if (( $CPU_THREADS >= 32 )); then
    RPS_MASK="ffffffff"
elif (( $CPU_THREADS >= 16 )); then
    RPS_MASK="ffff"
elif (( $CPU_THREADS >= 8 )); then
    RPS_MASK="ff"
elif (( $CPU_THREADS >= 4 )); then
    RPS_MASK="f"
else
    RPS_MASK="3"
fi

if [[ "$TESTING_MODE" == "true" ]];then
    echo "$CPU_THREADS"
fi

for NIC in /sys/class/net/*; do
    NIC=$(basename "$NIC") #Basename: Keeps only the final part of the path, ex. /sys/class/net/enp5s0 -> NIC=enp5s0
NIC_SYSFS_PATH=/sys/class/net/$NIC
echo on | tee "$NIC_SYSFS_PATH/power/control"
    echo enabled | tee "$NIC_SYSFS_PATH/power/async"

    [[ "$NIC" == "lo" ]] && continue

    for RX_QUEUE in /sys/class/net/$NIC/queues/rx-*; do
        [[ -e "$RX_QUEUE/rps_cpus" ]] || continue

        echo "$RPS_MASK" |  tee "$RX_QUEUE/rps_cpus"
    done
done

if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then

    if [[ $CPU_CLASS == "verylow" ]]; then
            #BUSY_POLL AND BUSY_READ CAN CAUSE KERNEL PANICS ON SPECIFIC HARDWARE
        #echo 0 |  tee /proc/sys/net/core/busy_poll
        #echo 0 |  tee /proc/sys/net/core/busy_read
        echo 64 |  tee /proc/sys/net/core/dev_weight
    elif [[ $CPU_CLASS == "low" ]]; then
        #echo 0 |  tee /proc/sys/net/core/busy_poll
        #echo 0 |  tee /proc/sys/net/core/busy_read
        echo 128 |  tee /proc/sys/net/core/dev_weight
    elif [[ $CPU_CLASS == "mid" ]]; then
        #echo 25 |  tee /proc/sys/net/core/busy_poll
        #echo 25 |  tee /proc/sys/net/core/busy_read
        echo 256 |  tee /proc/sys/net/core/dev_weight
    elif [[ $CPU_CLASS == "high" ]]; then
        #echo 50 |  tee /proc/sys/net/core/busy_poll
        #echo 50 |  tee /proc/sys/net/core/busy_read
        echo 512 |  tee /proc/sys/net/core/dev_weight
    fi

    echo 1 |  tee /proc/sys/net/ipv4/tcp_low_latency
fi