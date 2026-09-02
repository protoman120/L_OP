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
        echo 0 | tee /proc/sys/kernel/sched_autogroup_enabled
    fi

    if [[ "$OPTIMIZATION_PROFILE_USECASE" == "gaming" ]]; then
        echo 1 | tee /proc/sys/kernel/sched_child_runs_first
    else
        echo 0 | tee /proc/sys/kernel/sched_child_runs_first
    fi

    if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
	    if [[ "$OPTIMIZATION_PROFILE_USECASE" == "gaming" || "$OPTIMIZATION_PROFILE_USECASE" == "desktop" ]]; then
		    if [[ "$CPU_CLASS" == "verylow" ]]; then
                echo 10000 | tee /proc/sys/kernel/sched_rt_runtime_us
            elif [[ "$CPU_CLASS" == "low" ]]; then
                echo 20000 | tee /proc/sys/kernel/sched_rt_runtime_us
            elif [[ $CPU_CLASS == "mid" ]]; then
                echo 30000 | tee /proc/sys/kernel/sched_rt_runtime_us
            elif [[ $CPU_CLASS == "high" ]]; then
                echo 40000 | tee /proc/sys/kernel/sched_rt_runtime_us
            fi
	    elif [[ $OPTIMIZATION_PROFILE_USECASE == "server" ]]; then
		    echo 80000 | tee /proc/sys/kernel/sched_rt_runtime_us
    	fi
    fi

}

kernel_memory_optimizations(){

    if [[ $RAM_CLASS == "verylow" ]]; then
		echo 1 | tee /sys/kernel/mm/lru_gen/enabled
	elif [[ $RAM_CLASS == "low" ]]; then
		echo 1 | tee /sys/kernel/mm/lru_gen/enabled
	elif [[ $RAM_CLASS == "mid" ]]; then
		echo 0 | tee /sys/kernel/mm/lru_gen/enabled
	elif [[ $RAM_CLASS == "high" ]]; then
		echo 0 | tee /sys/kernel/mm/lru_gen/enabled
	elif [[ $RAM_CLASS == "veryhigh" ]]; then
		echo 0 | tee /sys/kernel/mm/lru_gen/enabled
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
	    echo "4 4 4 4" | tee /proc/sys/kernel/printk
    else
	    echo "4 4 4 4" | tee /proc/sys/kernel/printk
    fi
}

kernel_debug_optimizations(){

    if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" || $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
        if [[ $CPU_CLASS == "verylow" ]]; then
            echo 5 | tee /proc/sys/kernel/hung_task_timeout_secs
		elif [[ $CPU_CLASS == "low" ]]; then
            echo 8 | tee /proc/sys/kernel/hung_task_timeout_secs
		elif [[ $CPU_CLASS == "mid" ]]; then
            echo 10 | tee /proc/sys/kernel/hung_task_timeout_secs
		elif [[ $CPU_CLASS == "high" ]]; then
            echo 20 | tee /proc/sys/kernel/hung_task_timeout_secs
		fi
    else
	    echo 60 | tee /proc/sys/kernel/hung_task_timeout_secs
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