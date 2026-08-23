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

intel_cpu_auto_power_tuner(){
	CURRENT_CPU_TDP_INTEL=$(cat /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw)
	CURRENT_CPU_TDP_INTEL_HUMAN_READABLE=$(($CURRENT_CPU_TDP_INTEL/1000000))

	if (( $CURRENT_CPU_TDP_INTEL_HUMAN_READABLE > 40 )); then
		TDP_DECREASE_VALUE=$(($CURRENT_CPU_TDP_INTEL/4)) #Limits power usage
		NEW_TDP=$(($CURRENT_CPU_TDP_INTEL-$TDP_DECREASE_VALUE))
		TDP_TO_APPLY=$NEW_TDP
	elif (( $CURRENT_CPU_TDP_INTEL_HUMAN_READABLE > 20 )); then
		TDP_DECREASE_VALUE=$(($CURRENT_CPU_TDP_INTEL/3)) #Limits power usage
		NEW_TDP=$(($CURRENT_CPU_TDP_INTEL-$TDP_DECREASE_VALUE))
		TDP_TO_APPLY=$NEW_TDP
	elif (( $CURRENT_CPU_TDP_INTEL_HUMAN_READABLE < 10 )); then
		TDP_NEW_VALUE=$(($CURRENT_CPU_TDP_INTEL_HUMAN_READABLE*2)) #Low-powered CPUs need to boost beyond TDP to keep up usable performance, without intervention from the script, it could boost even higher on it's own.
		NEW_TDP=$(($TDP_NEW_VALUE*1000000))
		TDP_TO_APPLY=$NEW_TDP
	else
		TDP_NEW_VALUE=$(($CURRENT_CPU_TDP_INTEL_HUMAN_READABLE)) #Limits power usage
		NEW_TDP=$(($TDP_NEW_VALUE*1000000))
		TDP_TO_APPLY=$NEW_TDP
	fi

	#INTEL ONLY:
	#Enables TDP control (NOT CONFIRMED TO WORK OR DO ANYHING YET)
	# echo 1 |  tee /sys/class/powercap/intel-rapl/enabled (ONLY NEEDS intel-rapl:0 TO BE SET)
	for CPU_POWERCAP in /sys/class/powercap/intel-rapl*/enabled; do
		echo 1 | tee "$CPU_POWERCAP"
	done
	#Applies TDP to current CPU
	for CPU_LIMIT in /sys/class/powercap/intel-rapl*/constraint_*_power_limit_uw; do
        echo "$TDP_TO_APPLY" | tee "$CPU_LIMIT"
        APPLIED_TDP=$(<"$CPU_LIMIT")
        if (( $TDP_TO_APPLY >= $APPLIED_TDP )); then
            export TDP_APPLIED_CORRECTLY="true"
        else
            export TDP_APPLIED_CORRECTLY="false"
        fi
    done
}

cpu_scheduler_optimizations(){
	#General Optimizations
	echo 0 |  tee /sys/kernel/debug/sched/tunable_scaling
	echo 0 |  tee /sys/kernel/debug/sched/verbose
	
	if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
        #NOTE: LOWERING "base_slice_ns" FURTHER WILL RESULT IN SERIOUS STUTTERING IN GAMING WORKLOADS
		if [[ $CPU_CLASS == "verylow" ]]; then
			if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
                echo 6000 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 100000000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 8 | tee /proc/sys/kernel/sched_numa_migrate
				echo 1 | tee /sys/kernel/debug/sched/nr_migrate
			elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
				echo 12000 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 250000000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 12 | tee /proc/sys/kernel/sched_numa_migrate
				echo 1 | tee /sys/kernel/debug/sched/nr_migrate
    		else
				echo 24000 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 500000000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 16 | tee /proc/sys/kernel/sched_numa_migrate
				echo 1 | tee /sys/kernel/debug/sched/nr_migrate
    		fi
		elif [[ $CPU_CLASS == "low" ]]; then
			if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
                echo 3000 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 50000000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 4 | tee /proc/sys/kernel/sched_numa_migrate
				echo 1 | tee /sys/kernel/debug/sched/nr_migrate
			elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
				echo 6000 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 75000000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 6 | tee /proc/sys/kernel/sched_numa_migrate
				echo 1 | tee /sys/kernel/debug/sched/nr_migrate
			else
				echo 12000 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 100000000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 8 | tee /proc/sys/kernel/sched_numa_migrate
				echo 1 | tee /sys/kernel/debug/sched/nr_migrate
		    	fi
		elif [[ $CPU_CLASS == "mid" ]]; then
			if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
                echo 1500 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 2500000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 2 | tee /proc/sys/kernel/sched_numa_migrate
				echo 2 | tee /sys/kernel/debug/sched/nr_migrate
			elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
				echo 3000 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 5000000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 3 | tee /proc/sys/kernel/sched_numa_migrate
				echo 2 | tee /sys/kernel/debug/sched/nr_migrate
			else
				echo 6000 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 5000000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 4 | tee /proc/sys/kernel/sched_numa_migrate
				echo 2 | tee /sys/kernel/debug/sched/nr_migrate
			fi
		elif [[ $CPU_CLASS == "high" ]]; then
			if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
				echo 750 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 1500000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 1 | tee /proc/sys/kernel/sched_numa_migrate
				echo 2 | tee /sys/kernel/debug/sched/nr_migrate
			elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
				echo 1500 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 2500000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 2 | tee /proc/sys/kernel/sched_numa_migrate
				echo 2 | tee /sys/kernel/debug/sched/nr_migrate
			else
				echo 3000 | tee /sys/kernel/debug/sched/base_slice_ns
				echo 2500000 | tee /sys/kernel/debug/sched/migration_cost_ns
				echo 2 | tee /proc/sys/kernel/sched_numa_migrate
				echo 2 | tee /sys/kernel/debug/sched/nr_migrate
			fi
		fi
	elif [[ "$CPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
		if [[ $CPU_CLASS == "verylow" ]]; then
			echo 1000000 |  tee /sys/kernel/debug/sched/base_slice_ns
			echo 5000000000 |  tee /sys/kernel/debug/sched/migration_cost_ns
            echo 256 |  tee /proc/sys/kernel/sched_numa_migrate
            echo 1 |  tee /sys/kernel/debug/sched/nr_migrate
		elif [[ $CPU_CLASS == "low" ]]; then
			echo 1250000 |  tee /sys/kernel/debug/sched/base_slice_ns
			echo 1000000000 |  tee /sys/kernel/debug/sched/migration_cost_ns
            echo 128 |  tee /proc/sys/kernel/sched_numa_migrate
            echo 2 |  tee /sys/kernel/debug/sched/nr_migrate
		elif [[ $CPU_CLASS == "mid" ]]; then
			echo 1500000 |  tee /sys/kernel/debug/sched/base_slice_ns
			echo 50000000 |  tee /sys/kernel/debug/sched/migration_cost_ns
            echo 64 |  tee /proc/sys/kernel/sched_numa_migrate
            echo 4 |  tee /sys/kernel/debug/sched/nr_migrate
		elif [[ $CPU_CLASS == "high" ]]; then
			echo 2000000 |  tee /sys/kernel/debug/sched/base_slice_ns
			echo 25000000 |  tee /sys/kernel/debug/sched/migration_cost_ns
            echo 32 |  tee /proc/sys/kernel/sched_numa_migrate
            echo 8 |  tee /sys/kernel/debug/sched/nr_migrate
		fi
	fi
}

cpu_performance_optimizations(){

	if [[ $CPU_CLASS == "verylow" ]]; then
		echo auto | tee "$CPU_PATH/power/control"
	else
		echo on | tee "$CPU_PATH/power/control"
	fi
	
	if [[ $OPTIMIZATION_PROFILE_USECASE == "server" ]]; then
        echo "enabled" | tee "$CPU_DIR/power/async"
    else
        echo "disabled" | tee "$CPU_DIR/power/async"
	fi

	if [[ $CPU_CLASS == "verylow" ]]; then
		CPU_GOVERNOR="ondemand"
		CPU_ENERGY_PERFORMANCE_PREFERENCE="balance_performance"
	elif [[ $CPU_CLASS == "low" ]]; then
		CPU_GOVERNOR="performance"
		CPU_ENERGY_PERFORMANCE_PREFERENCE="balance_performance"
	elif [[ $CPU_CLASS == "mid" ]]; then
		CPU_GOVERNOR="performance"
		CPU_ENERGY_PERFORMANCE_PREFERENCE="performance"
	elif [[ $CPU_CLASS == "high" ]]; then
		CPU_GOVERNOR="performance"
		CPU_ENERGY_PERFORMANCE_PREFERENCE="performance" 
	fi

	for ((i=0; i<CPU_THREADS; i++)); do
	    CPU_DIR="$CPU_PATH/cpu$i"

	    if [[ $CPU_CLASS == "verylow" ]]; then
		    echo auto | tee "$CPU_DIR/power/control"
	    else
		    echo on | tee "$CPU_DIR/power/control"
	    fi
	    
	    if [[ $OPTIMIZATION_PROFILE_USECASE == "server" ]]; then
	    	echo "enabled" | tee "$CPU_DIR/power/async"
	    else
	    	echo "disabled" | tee "$CPU_DIR/power/async" #Specially for gaming, it has to be disabled, else it gives rendering issues, specially with frame generation
	    fi

	    echo "$CPU_GOVERNOR" | tee "$CPU_DIR/cpufreq/scaling_governor"
	    echo "$CPU_ENERGY_PERFORMANCE_PREFERENCE" | tee "$CPU_DIR/cpufreq/energy_performance_preference"
	done
	
}

cpu_frequency_optimizations(){
    #Slightly reduces max freq to lower temperatures, to compensate, min freq in increased

    if [[ $TDP_APPLIED_CORRECTLY == "true" ]]; then
	    if [[ $CPU_CLASS == "verylow" ]]; then
		    CPU_MIN_PERF=$(( CPU_MAX_FREQ * 10 / 100 ))
		    CPU_MAX_PERF=$(( CPU_MAX_FREQ * 75 / 100 ))
	    elif [[ $CPU_CLASS == "low" ]]; then
		    CPU_MIN_PERF=$(( CPU_MAX_FREQ * 15 / 100 ))
		    CPU_MAX_PERF=$(( CPU_MAX_FREQ * 80 / 100 ))
	    elif [[ $CPU_CLASS == "mid" ]]; then
		    CPU_MIN_PERF=$(( CPU_MAX_FREQ * 20 / 100 ))
		    CPU_MAX_PERF=$(( CPU_MAX_FREQ * 85 / 100 ))
	    elif [[ $CPU_CLASS == "high" ]]; then
		    CPU_MIN_PERF=$(( CPU_MAX_FREQ * 25 / 100 ))
		    CPU_MAX_PERF=$(( CPU_MAX_FREQ * 85 / 100 ))
	    fi
    else
	    if [[ $CPU_CLASS == "verylow" ]]; then
		    CPU_MIN_PERF=$(( CPU_MAX_FREQ * 5 / 100 ))
		    CPU_MAX_PERF=$(( CPU_MAX_FREQ * 60 / 100 ))
	    elif [[ $CPU_CLASS == "low" ]]; then
		    CPU_MIN_PERF=$(( CPU_MAX_FREQ * 5 / 100 ))
		    CPU_MAX_PERF=$(( CPU_MAX_FREQ * 60 / 100 ))
	    elif [[ $CPU_CLASS == "mid" ]]; then
		    CPU_MIN_PERF=$(( CPU_MAX_FREQ * 10 / 100 ))
		    CPU_MAX_PERF=$(( CPU_MAX_FREQ * 65 / 100 ))
	    elif [[ $CPU_CLASS == "high" ]]; then
		    CPU_MIN_PERF=$(( CPU_MAX_FREQ * 10 / 100 ))
		    CPU_MAX_PERF=$(( CPU_MAX_FREQ * 65 / 100 ))
	    fi
    fi
    
    for ((i=0; i<CPU_THREADS; i++)); do
	CPU_DIR="$CPU_PATH/cpu$i"
    	echo $CPU_MAX_PERF | tee $CPU_DIR/cpufreq/scaling_max_freq
    	echo $CPU_MIN_PERF | tee $CPU_DIR/cpufreq/scaling_min_freq
    done

}

if [[ "$@" == "cpu_scheduler_optimizations" ]]; then
    cpu_scheduler_optimizations
elif [[ "$@" == "cpu_performance_optimizations" ]]; then
    cpu_performance_optimizations
elif [[ "$@" == "intel_cpu_auto_power_tuner" ]]; then
    intel_cpu_auto_power_tuner
elif [[ "$@" == "cpu_frequency_optimizations" ]]; then
    cpu_frequency_optimizations
else
    cpu_scheduler_optimizations
    cpu_performance_optimizations
    if [[ "$CPU_COOLING_OPTIMIZATION" == "enabled" ]]; then
        if [[ "$CPU_VENDOR_ID" == "GenuineIntel" ]]; then
            intel_cpu_auto_power_tuner
        elif [[ "$CPU_VENDOR_ID" == "AuthenticAMD" ]]; then
            #amd_cpu_power_tuner
            echo ""
        fi
        cpu_frequency_optimizations
    fi
fi