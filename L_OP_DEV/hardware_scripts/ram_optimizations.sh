#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP (OPTIMIZATIONS)
source ./utility_scripts/script_directories.sh
source $SAVED_OPTIMIZATION_GOALS
source $SAVED_CPU_DATA
source $SAVED_RAM_DATA
source $SAVED_ROOT_STORAGE_DATA
source $SAVED_SWAP_STORAGE_DATA
source $SAVED_OS_DATA
source $SAVED_DE_DATA
source $SAVED_BOOTLOADER_DATA
##################################################################

ram_swappiness(){
	if [[ "$RAM_OPTIMIZATION_GOAL" == "latency" ]]; then
	
		if [[ $RAM_CLASS == "verylow" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 200 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 80 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 100 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
            	echo 40 |  tee /proc/sys/vm/swappiness
				echo 150 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		elif [[ $RAM_CLASS == "low" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 150 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 40 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 50 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
            	echo 30 |  tee /proc/sys/vm/swappiness
				echo 100 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		elif [[ $RAM_CLASS == "mid" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 100 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 12 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 25 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
            	echo 20 |  tee /proc/sys/vm/swappiness
				echo 50 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		elif [[ $RAM_CLASS == "high" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 50 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 5 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 10 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
            	echo 10 |  tee /proc/sys/vm/swappiness
				echo 25 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		elif [[ $RAM_CLASS == "veryhigh" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 25 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 1 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 5 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
            	echo 5 |  tee /proc/sys/vm/swappiness
				echo 10 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		fi
	
	elif [[ "$RAM_OPTIMIZATION_GOAL" == "throughput" ]]; then
		if [[ $RAM_CLASS == "verylow" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 300 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 100 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 200 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
				echo 300 |  tee /proc/sys/vm/swappiness
				echo 250 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		elif [[ $RAM_CLASS == "low" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 280 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 50 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 150 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
				echo 280 |  tee /proc/sys/vm/swappiness
				echo 200 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		elif [[ $RAM_CLASS == "mid" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 260 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 25 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 100 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
				echo 260 |  tee /proc/sys/vm/swappiness
				echo 150 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		elif [[ $RAM_CLASS == "high" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 240 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 10 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 50 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
				echo 240 |  tee /proc/sys/vm/swappiness
				echo 100 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		elif [[ $RAM_CLASS == "veryhigh" ]]; then
			if [[ $SYSTEM_SWAP_PARTITION_DETECTED == "true" ]]; then
				echo 220 |  tee /proc/sys/vm/swappiness
				if [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
					echo 5 |  tee /proc/sys/vm/vfs_cache_pressure
				else
					echo 25 |  tee /proc/sys/vm/vfs_cache_pressure
				fi
			else
				echo 220 |  tee /proc/sys/vm/swappiness
				echo 50 |  tee /proc/sys/vm/vfs_cache_pressure
			fi
		fi
	fi
	
}

ram_deduplication(){

	#Enable RAM deduplication:
	echo 1 |  tee /sys/kernel/mm/ksm/run
	
	#LATENCY FOCUSED RAM DEDUPLICATION:
	if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
		if [[ $CPU_CLASS == "verylow" ]]; then
			echo 250 |  tee /sys/kernel/mm/ksm/pages_to_scan
			echo 40 |  tee /sys/kernel/mm/ksm/sleep_millisecs
			echo 256000 |  tee /sys/kernel/mm/ksm/max_page_sharing
		elif [[ $CPU_CLASS == "low" ]]; then
			echo 500 |  tee /sys/kernel/mm/ksm/pages_to_scan
			echo 30 |  tee /sys/kernel/mm/ksm/sleep_millisecs
			echo 512000 |  tee /sys/kernel/mm/ksm/max_page_sharing
		elif [[ $CPU_CLASS == "mid" ]]; then
			echo 750 |  tee /sys/kernel/mm/ksm/pages_to_scan
			echo 20 |  tee /sys/kernel/mm/ksm/sleep_millisecs
			echo 768000 |  tee /sys/kernel/mm/ksm/max_page_sharing
		elif [[ $CPU_CLASS == "high" ]]; then
			echo 1000 |  tee /sys/kernel/mm/ksm/pages_to_scan
			echo 10 |  tee /sys/kernel/mm/ksm/sleep_millisecs
			echo 1024000 |  tee /sys/kernel/mm/ksm/max_page_sharing
		else
			echo "ERROR WITH MEMORY DEDUPLICATION: ERROR DETECTING CPU_CLASS, SKIPPING"
		fi
		
	#THROUGHPUT FOCUSED RAM DEDUPLICATION:
	elif [[ "$CPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
		if [[ $CPU_CLASS == "verylow" ]]; then
			echo 1250 |  tee /sys/kernel/mm/ksm/pages_to_scan
			echo 200 |  tee /sys/kernel/mm/ksm/sleep_millisecs
			echo 1280000 |  tee /sys/kernel/mm/ksm/max_page_sharing
		elif [[ $CPU_CLASS == "low" ]]; then
			echo 1500 |  tee /sys/kernel/mm/ksm/pages_to_scan
			echo 200 |  tee /sys/kernel/mm/ksm/sleep_millisecs
			echo 1536000 |  tee /sys/kernel/mm/ksm/max_page_sharing
		elif [[ $CPU_CLASS == "mid" ]]; then
			echo 1750 |  tee /sys/kernel/mm/ksm/pages_to_scan
			echo 200 |  tee /sys/kernel/mm/ksm/sleep_millisecs
			echo 1792000 |  tee /sys/kernel/mm/ksm/max_page_sharing
		elif [[ $CPU_CLASS == "high" ]]; then
			echo 2000 |  tee /sys/kernel/mm/ksm/pages_to_scan
			echo 200 |  tee /sys/kernel/mm/ksm/sleep_millisecs
			echo 2048000 |  tee /sys/kernel/mm/ksm/max_page_sharing
		else
			echo "ERROR WITH MEMORY DEDUPLICATION: ERROR DETECTING CPU_CLASS, SKIPPING"
		fi
	fi	
}

ram_vm_optimizations(){

    source "$SCRIPT_SAVED_RAM_DATA_FILE"
	
    if [[ $STORAGE_ROOT_DEVICE_TYPE == "hdd" ]]; then
	    if [[ $RAM_CLASS == "verylow" ]]; then
		    echo 70 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 400 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 65536 |  tee /proc/sys/vm/min_free_kbytes
		    echo 262144 |  tee /proc/sys/vm/max_map_count
		    echo 1500 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 500 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "low" ]]; then
		    echo 80 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 350 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 131072 |  tee /proc/sys/vm/min_free_kbytes
		    echo 1750 | tee /proc/sys/vm/dirty_expire_centisecs
            echo 750 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "mid" ]]; then
		    echo 90 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 300 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 262144 |  tee /proc/sys/vm/min_free_kbytes
		    echo 524288 |  tee /proc/sys/vm/max_map_count
		    echo 2000 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 1000 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "high" ]]; then
		    echo 95 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 250 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 524288 |  tee /proc/sys/vm/min_free_kbytes
		    echo 524288 |  tee /proc/sys/vm/max_map_count
		    echo 2250 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 1250 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "veryhigh" ]]; then
		    echo 100 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 200 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 1 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 1048576 |  tee /proc/sys/vm/min_free_kbytes
		    echo 1048576 |  tee /proc/sys/vm/max_map_count
		    echo 3500 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 1500 | tee /proc/sys/vm/dirty_writeback_centisecs
	    fi

    elif [[ $STORAGE_ROOT_DEVICE_TYPE == "usb" ]]; then
	    if [[ $RAM_CLASS == "verylow" ]]; then
		    echo 70 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 5 |  tee /proc/sys/vm/dirty_ratio
		    #echo 1 |  tee /proc/sys/vm/dirty_background_ratio
		    echo 400 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 65536 |  tee /proc/sys/vm/min_free_kbytes
		    echo 262144 |  tee /proc/sys/vm/max_map_count
            #Changing these value seems to help lower the USB device's temps, very important for portable installs, specially SD cards which can get VERY HOT under I/O pressure. NOTE: Using either too low or too high values can create extremely high temperatures for target device, use carefully.
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 1000 | tee /proc/sys/vm/dirty_expire_centisecs #Expire after 10 seconds
		    echo 1500 | tee /proc/sys/vm/dirty_writeback_centisecs
		    echo 5 | tee /proc/sys/vm/laptop_mode
	    elif [[ $RAM_CLASS == "low" ]]; then
		    echo 80 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 5 |  tee /proc/sys/vm/dirty_ratio
		    #echo 1 |  tee /proc/sys/vm/dirty_background_ratio
		    echo 350 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 131072 |  tee /proc/sys/vm/min_free_kbytes
		    #Lowering these value seems to help lower the USB device's temps, very important for portable installs, specially SD cards which can get VERY HOT under I/O pressure
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 1250 | tee /proc/sys/vm/dirty_expire_centisecs #Expire after 15 seconds
		    echo 1600 | tee /proc/sys/vm/dirty_writeback_centisecs
    	    echo 5 | tee /proc/sys/vm/laptop_mode
	    elif [[ $RAM_CLASS == "mid" ]]; then
		    echo 90 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 5 |  tee /proc/sys/vm/dirty_ratio
		    #echo 2 |  tee /proc/sys/vm/dirty_background_ratio
		    echo 300 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 262144 |  tee /proc/sys/vm/min_free_kbytes
		    echo 524288 |  tee /proc/sys/vm/max_map_count
		    #Lowering these value seems to help lower the USB device's temps, very important for portable installs, specially SD cards which can get VERY HOT under I/O pressure
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 1500 | tee /proc/sys/vm/dirty_expire_centisecs #Expire after 25 seconds
		    echo 1700 | tee /proc/sys/vm/dirty_writeback_centisecs
    	    echo 5 | tee /proc/sys/vm/laptop_mode
	    elif [[ $RAM_CLASS == "high" ]]; then
		    echo 95 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 5 |  tee /proc/sys/vm/dirty_ratio
		    #echo 1 |  tee /proc/sys/vm/dirty_background_ratio
		    echo 250 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 524288 |  tee /proc/sys/vm/min_free_kbytes
		    echo 524288 |  tee /proc/sys/vm/max_map_count
            #Lowering these value seems to help lower the USB device's temps, very important for portable installs, specially SD cards which can get VERY HOT under I/O pressure
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 1750 | tee /proc/sys/vm/dirty_expire_centisecs #Expire after 40 seconds
		    echo 1800 | tee /proc/sys/vm/dirty_writeback_centisecs
		    echo 5 | tee /proc/sys/vm/laptop_mode
	    elif [[ $RAM_CLASS == "veryhigh" ]]; then
		    echo 100 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 5 |  tee /proc/sys/vm/dirty_ratio
		    #echo 1 |  tee /proc/sys/vm/dirty_background_ratio
		    echo 200 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 1 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 1048576 |  tee /proc/sys/vm/min_free_kbytes
		    echo 1048576 |  tee /proc/sys/vm/max_map_count
    	    #Lowering these value seems to help lower the USB device's temps, very important for portable installs, specially SD cards which can get VERY HOT under I/O pressure
		    echo $((32 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 32 MB
		    echo $((128 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 128 MB
		    echo 2000 | tee /proc/sys/vm/dirty_expire_centisecs #Expire after 60 seconds
		    echo 2000 | tee /proc/sys/vm/dirty_writeback_centisecs
    	    echo 5 | tee /proc/sys/vm/laptop_mode
	    fi

    elif [[ $STORAGE_ROOT_DEVICE_TYPE == "ssd" ]]; then
	    if [[ $RAM_CLASS == "verylow" ]]; then
		    echo 70 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 5 |  tee /proc/sys/vm/dirty_ratio
		    #echo 2 |  tee /proc/sys/vm/dirty_background_ratio
		    echo $((256 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 256 MB
		    echo $((512 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 512 MB
		    echo 400 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 65536 |  tee /proc/sys/vm/min_free_kbytes
		    echo 262144 |  tee /proc/sys/vm/max_map_count
		    echo 1500 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 500 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "low" ]]; then
		    echo 80 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 10 |  tee /proc/sys/vm/dirty_ratio
		    #echo 5 |  tee /proc/sys/vm/dirty_background_ratio
		    echo $((512 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 512 MB
		    echo $((1024 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 1048 MB
		    echo 350 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 131072 |  tee /proc/sys/vm/min_free_kbytes
		    echo 2000 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 750 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "mid" ]]; then
		    echo 90 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 15 |  tee /proc/sys/vm/dirty_ratio
		    #echo 10 |  tee /proc/sys/vm/dirty_background_ratio
		    echo $((1024 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 1024 MB
		    echo $((2048 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 2048 MB
		    echo 300 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 262144 |  tee /proc/sys/vm/min_free_kbytes
		    echo 524288 |  tee /proc/sys/vm/max_map_count
		    echo 2500 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 1000 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "high" ]]; then
		    echo 95 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 20 |  tee /proc/sys/vm/dirty_ratio
		    #echo 15 |  tee /proc/sys/vm/dirty_background_ratio
		    echo $((2048 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 2048 MB
		    echo $((4096 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 4096 MB
		    echo 250 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 524288 |  tee /proc/sys/vm/min_free_kbytes
		    echo 524288 |  tee /proc/sys/vm/max_map_count
		    echo 3000 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 1500 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "veryhigh" ]]; then
		    echo 100 |  tee /proc/sys/vm/overcommit_ratio
		    #echo 25 |  tee /proc/sys/vm/dirty_ratio
		    #echo 20 |  tee /proc/sys/vm/dirty_background_ratio
		    echo $((4096 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 2048 MB
		    echo $((8192 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 8192 MB
		    echo 200 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 1 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 1048576 |  tee /proc/sys/vm/min_free_kbytes
		    echo 1048576 |  tee /proc/sys/vm/max_map_count
		    echo 3500 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 2000 | tee /proc/sys/vm/dirty_writeback_centisecs
	    fi

    elif [[ $STORAGE_ROOT_DEVICE_TYPE == "nvme" ]]; then
	    if [[ $RAM_CLASS == "verylow" ]]; then
		    echo 70 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((256 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 256 MB
		    echo $((512 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 512 MB
		    echo 400 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 65536 |  tee /proc/sys/vm/min_free_kbytes
		    echo 262144 |  tee /proc/sys/vm/max_map_count
		    echo 1500 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 500 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "low" ]]; then
		    echo 80 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((512 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 512 MB
		    echo $((1024 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 1048 MB
		    echo 350 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 131072 |  tee /proc/sys/vm/min_free_kbytes
		    echo 2000 | tee /proc/sys/vm/dirty_expire_centisecs
    	    echo 750 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "mid" ]]; then
		    echo 90 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((1024 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 1024 MB
		    echo $((2048 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 2048 MB
		    echo 300 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 262144 |  tee /proc/sys/vm/min_free_kbytes
		    echo 524288 |  tee /proc/sys/vm/max_map_count
		    echo 2500 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 1000 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "high" ]]; then
		    echo 95 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((2048 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 2048 MB
		    echo $((4096 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 4096 MB
		    echo 250 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 0 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 524288 |  tee /proc/sys/vm/min_free_kbytes
		    echo 524288 |  tee /proc/sys/vm/max_map_count
		    echo 3000 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 1500 | tee /proc/sys/vm/dirty_writeback_centisecs
	    elif [[ $RAM_CLASS == "veryhigh" ]]; then
		    echo 100 |  tee /proc/sys/vm/overcommit_ratio
		    echo $((4096 * 1024 * 1024)) | tee /proc/sys/vm/dirty_background_bytes #Start flushing at 2048 MB
		    echo $((8192 * 1024 * 1024)) | tee /proc/sys/vm/dirty_bytes #Hard cap at 8192 MB
		    echo 200 |  tee /proc/sys/vm/watermark_scale_factor
		    echo 0 |  tee /proc/sys/vm/watermark_boost_factor
		    echo 1 |  tee /proc/sys/vm/page-cluster
		    echo 1 |  tee /proc/sys/vm/stat_interval
		    echo 1048576 |  tee /proc/sys/vm/min_free_kbytes
		    echo 1048576 |  tee /proc/sys/vm/max_map_count
		    echo 3500 | tee /proc/sys/vm/dirty_expire_centisecs
		    echo 2000 | tee /proc/sys/vm/dirty_writeback_centisecs
	    fi
    fi

    if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
	    if [[ $CPU_CLASS == "verylow" ]]; then
	        echo 1 |  tee /proc/sys/vm/overcommit_memory
	        echo 0 |  tee /proc/sys/vm/compaction_proactiveness
	        echo 1 |  tee /proc/sys/vm/page_lock_unfairness
	    elif [[ $CPU_CLASS == "low" ]]; then
	        echo 1 |  tee /proc/sys/vm/overcommit_memory
	        echo 0 |  tee /proc/sys/vm/compaction_proactiveness
	        echo 2 |  tee /proc/sys/vm/page_lock_unfairness
	    elif [[ $CPU_CLASS == "mid" ]]; then
	        echo 0 |  tee /proc/sys/vm/overcommit_memory
	        echo 0 |  tee /proc/sys/vm/compaction_proactiveness
	        echo 3 |  tee /proc/sys/vm/page_lock_unfairness
	    elif [[ $CPU_CLASS == "high" ]]; then
	        echo 0 |  tee /proc/sys/vm/overcommit_memory
	        echo 0 |  tee /proc/sys/vm/compaction_proactiveness
	        echo 5 |  tee /proc/sys/vm/page_lock_unfairness
	    fi
    elif [[ "$CPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
	    if [[ $CPU_CLASS == "verylow" ]]; then
	        echo 1 |  tee /proc/sys/vm/overcommit_memory
	        echo 5 |  tee /proc/sys/vm/compaction_proactiveness
	        echo 5 |  tee /proc/sys/vm/page_lock_unfairness
	    elif [[ $CPU_CLASS == "low" ]]; then
	        echo 1 |  tee /proc/sys/vm/overcommit_memory
	        echo 10 |  tee /proc/sys/vm/compaction_proactiveness
	        echo 8 |  tee /proc/sys/vm/page_lock_unfairness
	    elif [[ $CPU_CLASS == "mid" ]]; then
	        echo 0 |  tee /proc/sys/vm/overcommit_memory
	        echo 20 |  tee /proc/sys/vm/compaction_proactiveness
	        echo 12 |  tee /proc/sys/vm/page_lock_unfairness
	    elif [[ $CPU_CLASS == "high" ]]; then
	        echo 0 |  tee /proc/sys/vm/overcommit_memory
	        echo 30 |  tee /proc/sys/vm/compaction_proactiveness
	        echo 16 |  tee /proc/sys/vm/page_lock_unfairness
	    fi
    fi
    echo 0 |  tee /proc/sys/vm/zone_reclaim_mode

}

ram_zram_configuration(){

	#DEFAULT VALUES
	ZRAM_ALGO="zstd"
	ZRAM_AMOUNT="2G"
	ZRAM_PRIORITY=500
    
	if [[ $CPU_CLASS == "verylow" ]]; then
        	ZRAM_ALGO="lz4"
	elif [[ $CPU_CLASS == "low" ]]; then
        	ZRAM_ALGO="lzo-rle"
	elif [[ $CPU_CLASS == "mid" ]]; then
        	ZRAM_ALGO="zstd"
	elif [[ $CPU_CLASS == "high" ]]; then
        	ZRAM_ALGO="zstd"
	fi

	if [[ $RAM_CLASS == "verylow" ]]; then
		ZRAM_AMOUNT=$((RAM_GB_PHYSICAL / 1))
	elif [[ $RAM_CLASS == "low" ]]; then
		ZRAM_AMOUNT=$((RAM_GB_PHYSICAL / 1))
	elif [[ $RAM_CLASS == "mid" ]]; then
		ZRAM_AMOUNT=$((RAM_GB_PHYSICAL / 1))
	elif [[ $RAM_CLASS == "high" ]]; then
		ZRAM_AMOUNT=$((RAM_GB_PHYSICAL / 2))
	elif [[ $RAM_CLASS == "veryhigh" ]]; then
		ZRAM_AMOUNT=$((RAM_GB_PHYSICAL / 2))
	fi

	modprobe zram
	echo ${ZRAM_ALGO} > /sys/block/zram0/comp_algorithm
	echo "${ZRAM_AMOUNT}G" > /sys/block/zram0/disksize
	mkswap /dev/zram0
	swapon -p ${ZRAM_PRIORITY} /dev/zram0
}

ram_swappiness
if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
	echo ""
else
	ram_deduplication
fi
ram_vm_optimizations
ram_zram_configuration

