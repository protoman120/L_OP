#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP (OPTIMIZATIONS)
source ./utility_scripts/script_directories.sh
source $SAVED_OPTIMIZATION_GOALS
source $SAVED_CPU_DATA
source $SAVED_RAM_DATA
source $SAVED_ROOT_STORAGE_DATA
source $SAVED_OS_DATA
source $SAVED_DE_DATA
source $SAVED_BOOTLOADER_DATA
##################################################################

:<<'COMMENT_BLOCK'
STORAGE OPTIMIZATIONS:

- /sys/block/$STORAGE_DEVICE/queue/scheduler -> Changes device's scheduler, which can be (by default):
    - none
        - Very low CPU overhead
        - Fist-in First-Out (FIFO) scheduling algorithm
    - mq-deadline
        - Balanced all-round option
        - Sorts I/O (Input/Output) resquests into 2 batches, one for reads, the other for writes
            - Read batches take priority over writes batches
            - After a batch is processed, the scheduler adjusts, based on the time it took to do the last operations.
        - Most useful for asyncronous write operations
    - kyber
        - Good for latency
        - Calculates the latency of every I/O (Input/Output) requests on the I/O layer
            - Target latencies can be configured for the following:
                - Reads
                - Cache misses
                - Syncronous write requests
    - bfq
        - Makes sure that no single application makes use of all the device's bandwith
        - Good for desktops or other interactive tasks
        - Good for slower media, like HDDs
        - Higher CPU overdead

- /sys/block/$STORAGE_DEVICE/queue/nomerges -> Controls request merging
    - Possible values:
        - 0 -> Full merging: Best throughput
        - 1 -> No large merging: Balanced
        - 2 -> No merging
            - Lower CPU Overhead
            - Worse throughput

- /sys/block/$STORAGE_DEVICE/queue/rq_affinity -> Controls which CPU cores can complete an issued I/O (Input/Output) request
    - Possible values:
        - 0 -> Lets any CPU core complete requests
        - 1 -> Uses one CPU core of the the same CPU group that issued the request
        - 2 -> Uses the same CPU core that isued the request

- /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb -> KB that are read ahead of sequentian read operations
    - For sequential reads, improves I/O (Input/Output) peroformance
    - If sequential reads of large files is requrired, it's good to set this similar or equal to "max_sectors_kb" of that storage device

- /sys/block/$STORAGE_DEVICE/queue/nr_requests -> Maximum number of I/O (Input/Output) requests that can be queued
    - With the "none" scheduler, this value can only be reduced


echo ""
COMMENT_BLOCK

source $SAVED_ROOT_STORAGE_DATA
source $SAVED_SWAP_STORAGE_DATA

READ_AHEAD_MB=1024

io_scheduler_optimizations(){

    #DEVICE SCHEDULER MUST BE UPDATED TO THE NEW ONE SET BEFORE THIS FUNCTION
    STORAGE_DEVICE_SCHEDULER=$(cat /sys/block/$STORAGE_DEVICE/queue/scheduler | grep -o '\[.*\]' | tr -d '[]')

    if [[ "$STORAGE_DEVICE_SCHEDULER" == "bfq" ]]; then
        #SETTINGS THAT CAN BE ADJUSTED:
        #SOURCE: https://docs.kernel.org/block/bfq-iosched.html
        #slice_idle: How long BFQ should idle for the next I/O request. (Default: 8)
        #strict_guarantees: (bool) Read source for details. (Default: 0)
        #back_seek_penalty: Used to compute the cost of backward seeking. (Default: 2)
        #back_seek_max: (in Kbytes) Allows the scheduler to anticipate requests in the “backward” direction and consider them as being the “next”. (Default: 16384)
        #fifo_expire_async: Timeout of asynchronous requests. (Default: 250)
        #fifo_expire_sync: Timeout of synchronous requests. (Default: 125)
        #low_latency: (bool) Enable/disable BFQ’s low latency mode. (Default: 1)
        #timeout_sync: Maximum amount of device time that can be given to a task (queue). (Default: 125)
        #max_budget: Maximum amount of service, measured in sectors, that can be provided to a BFQ queue. (Default: 0)
        if [[ "$STORAGE_DEVICE_TYPE" == "hdd" ]]; then
            if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 20 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 15000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 250 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 125 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "low" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 18 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 14000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 240 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 120 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "mid" ]]; then
                    #BOOL VALUES:
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 13000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 230 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 115 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "high" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 12000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 220 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 110 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 23000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 330 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 165 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "low" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 22000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 320 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 160 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "mid" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 21000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 310 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 155 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "high" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 20000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 300 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 150 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            fi
        elif [[ "$STORAGE_DEVICE_TYPE" == "usb" ]]; then
            if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 40 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 10000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 200 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 100 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "low" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 38 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 9000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 190 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 95 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "mid" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 36 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 8000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 180 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 90 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "high" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 7000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 170 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 85 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                fi
            elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 20 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 18000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 280 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 140 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "low" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 5 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 18 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 17000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 270 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 135 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "mid" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 16000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 260 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 130 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "high" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 3 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 15000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 250 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 125 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            fi
        elif [[ "$STORAGE_DEVICE_TYPE" == "ssd" ]]; then
            if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 5 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 5 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 5000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 150 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 75 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "low" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 4500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 140 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 70 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "mid" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 3 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 4000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 130 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 65 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "high" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 3500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 120 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 60 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 3 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 3 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 13000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 230 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 115 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "low" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 12000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 220 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 110 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "mid" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 11000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 210 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 105 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "high" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 10000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 200 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 100 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            fi
        elif [[ "$STORAGE_DEVICE_TYPE" == "nvme" ]]; then
            if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 2500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 100 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 50 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "low" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 3 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 2000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 90 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 45 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "mid" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 1500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 80 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 40 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "high" ]]; then
                    #BOOL VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 1000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 70 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 35 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                fi
            elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 8000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 180 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 90 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "low" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 7000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 170 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 85 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "mid" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 6000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 160 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 80 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                elif [[ $CPU_CLASS == "high" ]]; then
                    #BOOL VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/low_latency
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/strict_guarantees
                    #VALUES:
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/slice_idle
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_penalty
                    echo 5000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/back_seek_max
                    echo 150 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_async
                    echo 75 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_expire_sync
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            fi
        fi
    elif [[ "$STORAGE_DEVICE_SCHEDULER" == "kyber" ]]; then
        #SETTINGS THAT CAN BE ADJUSTED:
        #SOURCE: https://docs.kernel.org/5.19/block/kyber-iosched.html
        #read_lat_nsec: Target latency for reads (in nanoseconds). (Default: 2000000)
        #write_lat_nsec: Target latency for synchronous writes (in nanoseconds). (Default: 10000000)
        #IMPORTANT: Kyber will throttle requests in order to meet these target latencies.
        if [[ "$STORAGE_DEVICE_TYPE" == "hdd" ]]; then
            if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 2000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 10000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 1950000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1900000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9500000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1850000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9250000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 2250000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 11250000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 2200000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 11000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 2150000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 10750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 2100000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 10500000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            fi
        elif [[ "$STORAGE_DEVICE_TYPE" == "usb" ]]; then
            if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 1900000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9500000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 1850000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9250000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1800000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 8750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 2150000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 10750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 2100000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 10500000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 2050000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 10250000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 2000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 10000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            fi
        elif [[ "$STORAGE_DEVICE_TYPE" == "ssd" ]]; then
            if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 1800000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 1750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 8750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1700000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 8500000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1650000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 8250000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 2050000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 10250000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 2000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 10000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1950000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1900000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9500000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            fi
        elif [[ "$STORAGE_DEVICE_TYPE" == "nvme" ]]; then
            if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 1700000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 8500000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 1650000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 8250000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1600000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 8000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1550000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 7750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 1950000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9750000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 1900000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9500000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1850000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9250000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1800000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_lat_nsec
                    echo 9000000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_lat_nsec
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo ""
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo ""
                fi
            fi
        fi
    elif [[ "$STORAGE_DEVICE_SCHEDULER" == "mq-deadline" ]]; then
        #SETTINGS THAT CAN BE ADJUSTED:
        #SOURCE: https://docs.kernel.org/block/deadline-iosched.html
        #read_expire: (in ms) (Default: 500)
        #write_expire: (in ms) (Default: 5000)
        #fifo_batch: Maximum number of requests per batch. Requests are grouped into batches of a particular data direction (read or write). (Default: 16)
        #writes_starved: Controls how many times it gives preference to reads over writes. (Default: 2)
        #front_merges: (bool) (Default: 1)
        if [[ "$STORAGE_DEVICE_TYPE" == "hdd" ]]; then
            if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 5000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved  
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 490 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4900 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 480 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4800 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 470 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4700 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                fi
            elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 580 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 5800 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 570 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 5700 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 18 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 560 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 5600 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 20 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 550 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 5500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 22 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo 18 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo 20 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo 22 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                fi
            fi
        elif [[ "$STORAGE_DEVICE_TYPE" == "usb" ]]; then
            if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 450 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 440 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4400 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 430 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4300 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 420 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4200 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo 18 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                fi
            elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 530 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 5300 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
		            echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 520 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 5200 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
		            echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 510 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 5100 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
		            echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/rSubscriu-meead_expire
                    echo 5000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo 18 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo 20 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                fi
            fi
        elif [[ "$STORAGE_DEVICE_TYPE" == "ssd" ]]; then
            if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 400 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 390 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 3900 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 380 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 3800 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 370 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 3700 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo 18 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo 20 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                fi
            elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 480 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4800 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 470 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4700 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 460 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4600 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 450 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo 18 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo 20 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo 22 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo 24 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo 26 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                fi
            fi
        elif [[ "$STORAGE_DEVICE_TYPE" == "nvme" ]]; then
            if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 350 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 3500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 12 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 340 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 3400 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 10 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 330 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 3300 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 320 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 3200 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 6 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo 14 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo 18 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo 20 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo 22 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                fi
            elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                if [[ $CPU_CLASS == "verylow" ]]; then
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 430 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4300 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "low" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 420 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4200 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 3 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "mid" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 410 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4100 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                elif [[ $CPU_CLASS == "high" ]]; then
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 400 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 4000 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/write_expire
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
                fi
                if [[ $RAM_CLASS == "verylow" ]]; then
                    echo 20 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "low" ]]; then
                    echo 22 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "mid" ]]; then
                    echo 24 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "high" ]]; then
                    echo 26 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                elif [[ $RAM_CLASS == "veryhigh" ]]; then
                    echo 28 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                fi
            fi
        fi
    fi

}

    for STORAGE_DEVICE in $(lsblk -d -n -o NAME,TYPE | awk '$2=="disk"{print $1}'); do
        
        STORAGE_DEVICE_PATH="/dev/$STORAGE_DEVICE"

        SAVED_STORAGE_DEVICE_DATA_FOLDER=$SAVED_STORAGE_DATA_FOLDER/$STORAGE_DEVICE
        SAVED_STORAGE_PARTITIONS_DATA_FOLDER=$SAVED_STORAGE_DEVICE_DATA_FOLDER/partitions
        
        SAVED_STORAGE_DEVICE_DATA_FILE=$SAVED_STORAGE_DEVICE_DATA_FOLDER/$SAVED_STORAGE_DEVICE_DATA_FILE_NAME

        for CURRENT_STORAGE_FILE in "$SAVED_STORAGE_DEVICE_DATA_FILE"; do

            source "$CURRENT_STORAGE_FILE"

            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iostats
        if [[ "$STORAGE_DEVICE_TYPE" == "hdd" ]]; then

            if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then
		        if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 2 |  tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		        elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    if [[ $CPU_CLASS == "low" ]]; then
                        echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    else
                        echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    fi
			        echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay			
		        fi
            elif [[ $CPU_CLASS == "mid" ]]; then
                if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo bfq | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "high" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinitySTORAGE_OPTI
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo bfq | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            fi

            #OPTIMIZED FOR SLOW STORAGE (HDD ONLY)
            if [[ $RAM_CLASS == "verylow" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 1)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 2)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "low" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 2)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 4)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "mid" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 4)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 8)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "high" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 8)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 16)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "veryhigh" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 16)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 32)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            fi

        elif [[ "$STORAGE_DEVICE_TYPE" == "usb" ]]; then
        
            if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
		            if [[ $CPU_CLASS == "low" ]]; then
                        echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    else
                        echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    fi
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "mid" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
	            elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo bfq | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
	            fi
            elif [[ $CPU_CLASS == "high" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo bfq | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            fi

            #OPTIMIZED FOR SLOW STORAGE (USB ONLY)
            if [[ $RAM_CLASS == "verylow" ]]; then
                if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB / 2)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 1)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "low" ]]; then
                if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 1)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 2)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "mid" ]]; then
                if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 2)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 4)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "high" ]]; then
                if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 4)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 8)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "veryhigh" ]]; then
                if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 8)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 16)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            fi

        elif [[ "$STORAGE_DEVICE_TYPE" == "ssd" ]]; then

            if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo none |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    if [[ $CPU_CLASS == "low" ]]; then
                        echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    else
                        echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    fi
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "mid" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
			        echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
			        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
			        echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
			        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "high" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		        elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		        fi
            fi

            #OPTIMIZED FOR FAST STORAGE (SSD ONLY)
            if [[ $RAM_CLASS == "verylow" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 2)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 4)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "low" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 4)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 8)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "mid" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 8)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 16)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "high" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 16)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 32)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "veryhigh" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 32)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 64)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            fi
        
        elif [[ "$STORAGE_DEVICE_TYPE" == "nvme" ]]; then

            if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo none |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    if [[ $CPU_CLASS == "low" ]]; then
                        echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    else
                        echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    fi
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "mid" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo none |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
	        	    echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
	 		        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
	        	    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "high" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo none |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            fi

            #OPTIMIZED FOR FAST STORAGE (NVME ONLY)
            if [[ $RAM_CLASS == "verylow" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 4)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 8)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "low" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 8)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 8)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "mid" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 16)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 32)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "high" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 32)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 64)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "veryhigh" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo $(($READ_AHEAD_MB * 64)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo $(($READ_AHEAD_MB * 128)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            fi
        fi
        #SWAP DEVICE CONFIG:
        if [[ "$STORAGE_SWAP_DEVICE" == "$STORAGE_DEVICE" && "$STORAGE_SWAP_DEVICE" != "$STORAGE_ROOT_DEVICE" ]]; then
            if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" || $CPU_CLASS == "mid" ]]; then
                echo mq-deadline |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
            else
                echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
            fi
            echo $(($READ_AHEAD_MB / 2)) | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
            echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
        fi
        io_scheduler_optimizations
        for STORAGE_PARTITION in $(lsblk -ln -o NAME,TYPE | awk '$2=="part"{print $1}'); do

            STORAGE_PARTITION_PATH="/dev/$STORAGE_PARTITION"
            STORAGE_PARTITION_PARENT_DEVICE=$(lsblk -no PKNAME "/dev/$STORAGE_PARTITION")
            STORAGE_PARTITION_FILE=$SAVED_STORAGE_DEVICE_DATA_FOLDER/partitions/$STORAGE_PARTITION/$SAVED_STORAGE_PARTITION_DATA_FILE_NAME

            for CURRENT_STORAGE_PARTITION_FILE in "$STORAGE_PARTITION_FILE"; do
                source "$CURRENT_STORAGE_PARTITION_FILE"

                if [[ $STORAGE_PARTITION_MOUNTPOINT == "/" ]]; then

                    if [[ $STORAGE_PARTITION_FILESYSTEM == "btrfs" ]]; then
                        STORAGE_REQUIRED_ARGS="defaults,subvol=@"
                    elif [[ $STORAGE_PARTITION_FILESYSTEM == "ext4" ]]; then
                        STORAGE_REQUIRED_ARGS="defaults,subvol=@"
                    fi

                elif [[ $STORAGE_PARTITION_MOUNTPOINT == "/home" ]]; then

                    if [[ $STORAGE_PARTITION_FILESYSTEM == "btrfs" ]]; then
                        STORAGE_REQUIRED_ARGS="defaults,subvol=@home"
                    elif [[ $STORAGE_PARTITION_FILESYSTEM == "ext4" ]]; then
                        STORAGE_REQUIRED_ARGS="defaults,subvol=@home"
                    fi

                else

                    if [[ $STORAGE_PARTITION_FILESYSTEM == "btrfs" ]]; then
                        STORAGE_REQUIRED_ARGS="nosuid,nodev,nofail,x-gvfs-show"
                    elif [[ $STORAGE_PARTITION_FILESYSTEM == "ext4" ]]; then
                        STORAGE_REQUIRED_ARGS="nosuid,nodev,nofail,x-gvfs-show"
                    elif [[ $STORAGE_PARTITION_FILESYSTEM == "swap" ]]; then
                        swapoff $STORAGE_PARTITION_PATH
                        swapon -p 250 $STORAGE_PARTITION_PATH
                    fi

                fi

                if [[ $STORAGE_PARTITION_FILESYSTEM == "btrfs" ]]; then

                    if [[ "$STORAGE_DEVICE_TYPE" == "hdd" ]]; then

                        if [[ $CPU_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,lazytime,noatime,relatime,compress=lzo,space_cache=v2"
                        elif [[ $CPU_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,lazytime,noatime,relatime,compress=zstd:3,space_cache=v2"
                        elif [[ $CPU_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,lazytime,noatime,relatime,compress=zstd:3,space_cache=v2"
                        elif [[ $CPU_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,lazytime,noatime,relatime,compress=zstd:5,space_cache=v2"
                        fi

                        if [[ $RAM_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=15"
                        elif [[ $RAM_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=30"
                        elif [[ $RAM_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=80"
                        elif [[ $RAM_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=120"
                        elif [[ $RAM_CLASS == "veryhigh" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=180"
                        fi

                        STORAGE_MOUNT_ARGS_CHANGED="true"

                    elif [[ "$STORAGE_DEVICE_TYPE" == "usb" ]]; then

                        if [[ $CPU_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=lzo,space_cache=v2"
                        elif [[ $CPU_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=zstd:1,space_cache=v2"
                        elif [[ $CPU_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=zstd:3,ssd,space_cache=v2"
                        elif [[ $CPU_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=zstd:5,ssd,space_cache=v2"
                        fi

                        if [[ $RAM_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=10"
                        elif [[ $RAM_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=15"
                        elif [[ $RAM_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=30"
                        elif [[ $RAM_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=50"
                        elif [[ $RAM_CLASS == "veryhigh" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=60"
                        fi

                        STORAGE_MOUNT_ARGS_CHANGED="true"

                    elif [[ "$STORAGE_DEVICE_TYPE" == "ssd" ]]; then

                        if [[ $CPU_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=lzo,space_cache=v2"
                        elif [[ $CPU_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=zstd:1,space_cache=v2"
                        elif [[ $CPU_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=zstd:3,space_cache=v2,ssd"
                        elif [[ $CPU_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=zstd:5,space_cache=v2,ssd"
                        fi

                        if [[ $RAM_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=15"
                        elif [[ $RAM_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=30"
                        elif [[ $RAM_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=60"
                        elif [[ $RAM_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=90"
                        elif [[ $RAM_CLASS == "veryhigh" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=120"
                        fi

                        STORAGE_MOUNT_ARGS_CHANGED="true"

                    elif [[ "$STORAGE_DEVICE_TYPE" == "nvme" ]]; then

                        if [[ $CPU_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=lzo,space_cache=v2"
                        elif [[ $CPU_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=zstd:1,space_cache=v2"
                        elif [[ $CPU_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=zstd:3,space_cache=v2,ssd"
                        elif [[ $CPU_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="nodatacow,noatime,lazytime,compress=zstd:5,space_cache=v2,ssd"
                        fi

                        if [[ $RAM_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=60"
                        elif [[ $RAM_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=90"
                        elif [[ $RAM_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=120"
                        elif [[ $RAM_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=150"
                        elif [[ $RAM_CLASS == "veryhigh" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=180"
                        fi

                        STORAGE_MOUNT_ARGS_CHANGED="true"

                    fi

                elif [[ $STORAGE_PARTITION_FILESYSTEM == "ext4" ]]; then

                    if [[ "$STORAGE_DEVICE_TYPE" == "hdd" ]]; then

                        if [[ $CPU_CLASS == "verylow" ]]; then
                           STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        elif [[ $CPU_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        elif [[ $CPU_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime"
                        elif [[ $CPU_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime"
                        fi

                        if [[ $RAM_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=60"
                        elif [[ $RAM_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=90"
                        elif [[ $RAM_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=120"
                        elif [[ $RAM_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=150"
                        elif [[ $RAM_CLASS == "veryhigh" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=180"
                        fi

                    elif [[ "$STORAGE_DEVICE_TYPE" == "usb" ]]; then

                        if [[ $CPU_CLASS == "verylow" ]]; then
                           STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        elif [[ $CPU_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        elif [[ $CPU_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        elif [[ $CPU_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        fi

                        if [[ $RAM_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=60"
                        elif [[ $RAM_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=90"
                        elif [[ $RAM_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=120"
                        elif [[ $RAM_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=150"
                        elif [[ $RAM_CLASS == "veryhigh" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=180"
                        fi

                    elif [[ "$STORAGE_DEVICE_TYPE" == "ssd" ]]; then

                        if [[ $CPU_CLASS == "verylow" ]]; then
                           STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        elif [[ $CPU_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        elif [[ $CPU_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime"
                        elif [[ $CPU_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime"
                        fi

                       if [[ $RAM_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=60"
                        elif [[ $RAM_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=90"
                        elif [[ $RAM_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=120"
                        elif [[ $RAM_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=150"
                        elif [[ $RAM_CLASS == "veryhigh" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=180"
                        fi

                    elif [[ "$STORAGE_DEVICE_TYPE" == "nvme" ]]; then

                        if [[ $CPU_CLASS == "verylow" ]]; then
                           STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        elif [[ $CPU_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime,data=writeback"
                        elif [[ $CPU_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime"
                        elif [[ $CPU_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_CPU="noatime"
                        fi

                        if [[ $RAM_CLASS == "verylow" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=60"
                        elif [[ $RAM_CLASS == "low" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=90"
                        elif [[ $RAM_CLASS == "mid" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=120"
                        elif [[ $RAM_CLASS == "high" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=150"
                        elif [[ $RAM_CLASS == "veryhigh" ]]; then
                            STORAGE_PARTITION_MOUNT_ARGS_RAM="commit=180"
                        fi

                    fi
                fi

                if [[ "$STORAGE_MOUNT_ARGS_CHANGED" == "true" ]]; then
                    STORAGE_NEW_MOUNT_ARGS="${STORAGE_REQUIRED_ARGS},${STORAGE_PARTITION_MOUNT_ARGS_CPU},${STORAGE_PARTITION_MOUNT_ARGS_RAM}"
                    mount -o remount,"$STORAGE_NEW_MOUNT_ARGS" "$STORAGE_PARTITION_MOUNTPOINT"
                fi

                if [[ "$STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP" == "true" ]]; then
                
                    STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"

                    if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP" == "true" ]]; then
                        HDD_STORAGE_OPTIMIZATION_GOAL="latency"
                    fi

                    if [[ "$HDD_OPTIMIZATION_GOAL_CHANGED_SWAP" == "true" ]]; then
                        USB_STORAGE_OPTIMIZATION_GOAL="latency"
                    fi
                    
                    if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP" == "true" ]]; then
                        SSD_STORAGE_OPTIMIZATION_GOAL="latency"
                    fi

                    if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP" == "true" ]]; then
                        NVME_STORAGE_OPTIMIZATION_GOAL="latency"
                    fi

                    HDD_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"
                    USB_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"
                    SSD_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"
                    NVME_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"

                fi
            done
        done
    done
done
