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

kernel_scheduler_optimizations(){

    if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
        echo 0 | tee /proc/sys/kernel/numa_balancing
    else
        echo 1 | tee /proc/sys/kernel/numa_balancing
    fi

    if [[ "$OPTIMIZATION_PROFILE_USECASE" == "gaming" ]]; then
        echo 1 | tee /proc/sys/kernel/sched_child_runs_first
    else
        echo 0 | tee /proc/sys/kernel/sched_child_runs_first
    fi

    if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
	    if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
		    #echo -1 | tee /proc/sys/kernel/sched_rt_runtime_us
            echo ""
    	elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
		    echo 950000 | tee /proc/sys/kernel/sched_rt_runtime_us
	    elif [[ $OPTIMIZATION_PROFILE_USECASE == "server" ]]; then
		    echo 950000 | tee /proc/sys/kernel/sched_rt_runtime_us
    	else
		    echo 950000 | tee /proc/sys/kernel/sched_rt_runtime_us
    	fi
    fi
}

kernel_memory_optimizations(){

	if [[ $RAM_CLASS == "verylow" ]]; then
		echo 0 | tee /sys/kernel/mm/lru_gen/enabled
	elif [[ $RAM_CLASS == "low" ]]; then
		echo 0 | tee /sys/kernel/mm/lru_gen/enabled
	elif [[ $RAM_CLASS == "mid" ]]; then
		echo 1 | tee /sys/kernel/mm/lru_gen/enabled
	elif [[ $RAM_CLASS == "high" ]]; then
		echo 3 | tee /sys/kernel/mm/lru_gen/enabled
	elif [[ $RAM_CLASS == "veryhigh" ]]; then
		echo 7 | tee /sys/kernel/mm/lru_gen/enabled
	fi
}

kernel_timer_optimizations(){

    if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
        echo 0 | tee /proc/sys/kernel/timer_migration
    else
        echo 1 | tee /proc/sys/kernel/timer_migration
    fi

}

kernel_logging_optimizations(){

    if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
	echo "3 3 3 3" | tee /proc/sys/kernel/printk
    elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
	echo "4 4 4 4" | tee /proc/sys/kernel/printk
    elif [[ $OPTIMIZATION_PROFILE_USECASE == "server" ]]; then
	echo "3 3 3 3" | tee /proc/sys/kernel/printk
    else
	echo "4 4 4 4" | tee /proc/sys/kernel/printk
    fi
}

kernel_debug_optimizations(){

    if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
	echo 0 | tee /proc/sys/kernel/hung_task_timeout_secs
    else
	echo 120 | tee /proc/sys/kernel/hung_task_timeout_secs
    fi

    if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
	echo 0 | tee /proc/sys/kernel/watchdog
    else
	echo 1 | tee /proc/sys/kernel/watchdog
    fi
}

kernel_scheduler_optimizations
kernel_memory_optimizations
kernel_timer_optimizations
kernel_logging_optimizations
kernel_debug_optimizations