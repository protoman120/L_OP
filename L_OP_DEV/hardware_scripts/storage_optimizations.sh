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

    for STORAGE_DEVICE in $(lsblk -d -n -o NAME,TYPE | awk '$2=="disk"{print $1}'); do
        
        STORAGE_DEVICE_PATH="/dev/$STORAGE_DEVICE"

        SAVED_STORAGE_DEVICE_DATA_FOLDER=$SAVED_STORAGE_DATA_FOLDER/$STORAGE_DEVICE
        SAVED_STORAGE_PARTITIONS_DATA_FOLDER=$SAVED_STORAGE_DEVICE_DATA_FOLDER/partitions
        
        SAVED_STORAGE_DEVICE_DATA_FILE=$SAVED_STORAGE_DEVICE_DATA_FOLDER/$SAVED_STORAGE_DEVICE_DATA_FILE_NAME

        for CURRENT_STORAGE_FILE in "$SAVED_STORAGE_DEVICE_DATA_FILE"; do

            source "$CURRENT_STORAGE_FILE"

            STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"

            if [[ "$STORAGE_SWAP_DEVICE" == "$STORAGE_DEVICE" && "$STORAGE_SWAP_DEVICE" != "$STORAGE_ROOT_DEVICE" ]]; then
                
                STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"
                HDD_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"
                USB_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"
                SSD_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"
                NVME_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="false"

                if [[ "$STORAGE_SWAP_DEVICE_TYPE" == "hdd" && "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    HDD_STORAGE_OPTIMIZATION_GOAL="throughput"
                    STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="true"
                    HDD_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="true"
                fi
                
                if [[ "$STORAGE_SWAP_DEVICE_TYPE" == "usb" && "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    USB_STORAGE_OPTIMIZATION_GOAL="throughput"
                    STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="true"
                    USB_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="true"
                fi

                if [[ "$STORAGE_SWAP_DEVICE_TYPE" == "ssd" && "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    SSD_STORAGE_OPTIMIZATION_GOAL="throughput"
                    STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="true"
                    SSD_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="true"
                fi

                if [[ "$STORAGE_SWAP_DEVICE_TYPE" == "nvme" && "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    NVME_STORAGE_OPTIMIZATION_GOAL="throughput"
                    STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="true"
                    NVME_STORAGE_OPTIMIZATION_GOAL_CHANGED_SWAP="true"
                fi

            fi

            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iostats

        if [[ "$STORAGE_DEVICE_TYPE" == "hdd" ]]; then
        
            if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then
		        if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo bfq | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 2 |  tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		            echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
		        elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
			        echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
			        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
			        echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
			        echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth			
		        fi
            elif [[ $CPU_CLASS == "mid" ]]; then
                if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo bfq | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                fi
            elif [[ $CPU_CLASS == "high" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinitySTORAGE_OPTI
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo bfq | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                fi
            fi

            #OPTIMIZED FOR SLOW STORAGE (HDD ONLY)
            if [[ $RAM_CLASS == "verylow" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 1024 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "low" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 2048 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 128 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "mid" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "high" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "veryhigh" ]]; then
            	if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 16384 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            fi

            if [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo 25 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved                   
            elif [[ "$HDD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo 500 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved  
            fi

        elif [[ "$STORAGE_DEVICE_TYPE" == "usb" ]]; then

            if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                fi
            elif [[ $CPU_CLASS == "mid" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		            echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
		            echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
	            elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
	            fi
            elif [[ $CPU_CLASS == "high" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo bfq |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
		            echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo mq-deadline | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                fi
            fi

            #OPTIMIZED FOR SLOW STORAGE (USB ONLY)
            if [[ $RAM_CLASS == "verylow" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "low" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 128 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "mid" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "high" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "veryhigh" ]]; then
            	if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    #read_ahead_kb SET TO 0 TO LOWER USB TEMPERATURES
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            fi
	    
	        if [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		        echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
		        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
	        elif [[ "$USB_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
		        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
	        fi

        elif [[ "$STORAGE_DEVICE_TYPE" == "ssd" ]]; then

            if [[ $CPU_CLASS == "verylow" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo none |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		            echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "low" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo kyber |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		            echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "mid" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo kyber |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
		            echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
			        echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
			        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
			        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
			        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "high" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo kyber |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
		            echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
		        elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		        fi
            fi

            #OPTIMIZED FOR FAST STORAGE (SSD ONLY)
            if [[ $RAM_CLASS == "verylow" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 128 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "low" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 256 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 128 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "mid" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 256 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "high" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 1024 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "veryhigh" ]]; then
            	if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 2048 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 1024 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            fi

	        if [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		        echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
	        elif [[ "$SSD_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
		        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
	        fi
        
        elif [[ "$STORAGE_DEVICE_TYPE" == "nvme" ]]; then

            if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo none |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "mid" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                    echo kyber |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                    echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
                    echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
	        	    echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
	 		        echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
	        	    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            elif [[ $CPU_CLASS == "high" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		            echo kyber |  tee /sys/block/$STORAGE_DEVICE/queue/scheduler
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
		            echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
		            echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
		            echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/fifo_batch
		            echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/async_depth
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    echo none | tee /sys/block/$STORAGE_DEVICE/queue/scheduler
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nomerges
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/front_merges
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/rq_affinity
                    echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll
                    echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/io_poll_delay
                fi
            fi

            #OPTIMIZED FOR FAST STORAGE (NVME ONLY)
            if [[ $RAM_CLASS == "verylow" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 0 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 128 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "low" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 1024 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 256 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "mid" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 16 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 2048 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 512 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "high" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 4 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 4096 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 1024 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            elif [[ $RAM_CLASS == "veryhigh" ]]; then
            	if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 8 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo 8192 | tee /sys/block/$STORAGE_DEVICE/queue/read_ahead_kb
                	echo 2048 | tee /sys/block/$STORAGE_DEVICE/queue/nr_requests
                fi
            fi

	        if [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "latency" ]]; then
		        echo 2 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
                echo 32 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
	        elif [[ "$NVME_STORAGE_OPTIMIZATION_GOAL" == "throughput" ]]; then
                echo 64 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/read_expire
		        echo 1 | tee /sys/block/$STORAGE_DEVICE/queue/iosched/writes_starved
	        fi
        fi

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
