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

cpu_scheduler_optimizations_apply_values(){

	if [[ "$CPU_TURNABLE_SCALING" != "" ]]; then
		echo $CPU_TURNABLE_SCALING |  tee /sys/kernel/debug/sched/tunable_scaling
	fi

	if [[ "$CPU_VERBOSE" != "" ]]; then
		echo $CPU_VERBOSE |  tee /sys/kernel/debug/sched/verbose
	fi

	if [[ "$CPU_BASE_SLICE_NS" != "" ]]; then
		echo $CPU_BASE_SLICE_NS | tee /sys/kernel/debug/sched/base_slice_ns
	fi

	if [[ "$CPU_MIGRATION_COST_NS" != "" ]]; then
		echo $CPU_MIGRATION_COST_NS | tee /sys/kernel/debug/sched/migration_cost_ns
	fi

	if [[ "$CPU_SCHED_NUMA_MIGRATE" != "" ]]; then
		echo $CPU_SCHED_NUMA_MIGRATE | tee /proc/sys/kernel/sched_numa_migrate
	fi

	if [[ "$CPU_NR_MIGRATE" != "" ]]; then
		echo $CPU_NR_MIGRATE | tee /sys/kernel/debug/sched/nr_migrate
	fi

}

cpu_scheduler_optimizations(){

	################################################################
	#VARIABLE INITIALIZATION:

	CPU_TURNABLE_SCALING=""
	CPU_VERBOSE=""
	CPU_BASE_SLICE_NS=""
	CPU_MIGRATION_COST_NS=""
	CPU_SCHED_NUMA_MIGRATE=""
	CPU_NR_MIGRATE=""

	################################################################

	#General Optimizations

	CPU_TURNABLE_SCALING=0
	CPU_VERBOSE=0
	
	if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
        #NOTE: LOWERING "base_slice_ns" FURTHER WILL RESULT IN SERIOUS STUTTERING IN GAMING WORKLOADS
		if [[ $CPU_CLASS == "verylow" ]]; then
			if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
				CPU_BASE_SLICE_NS=4000
				CPU_MIGRATION_COST_NS=100000000
				CPU_SCHED_NUMA_MIGRATE=8
				CPU_NR_MIGRATE=1
			elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
				CPU_BASE_SLICE_NS=8000
				CPU_MIGRATION_COST_NS=250000000
				CPU_SCHED_NUMA_MIGRATE=12
				CPU_NR_MIGRATE=1
    		else
				CPU_BASE_SLICE_NS=16000
				CPU_MIGRATION_COST_NS=500000000
				CPU_SCHED_NUMA_MIGRATE=16
				CPU_NR_MIGRATE=1
    		fi
		elif [[ $CPU_CLASS == "low" ]]; then
			if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
				CPU_BASE_SLICE_NS=2000
				CPU_MIGRATION_COST_NS=50000000
				CPU_SCHED_NUMA_MIGRATE=4
				CPU_NR_MIGRATE=1
			elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
				CPU_BASE_SLICE_NS=4000
				CPU_MIGRATION_COST_NS=75000000
				CPU_SCHED_NUMA_MIGRATE=6
				CPU_NR_MIGRATE=1
			else
				CPU_BASE_SLICE_NS=8000
				CPU_MIGRATION_COST_NS=100000000
				CPU_SCHED_NUMA_MIGRATE=8
				CPU_NR_MIGRATE=1
			fi
		elif [[ $CPU_CLASS == "mid" ]]; then
			if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
				CPU_BASE_SLICE_NS=1000
				CPU_MIGRATION_COST_NS=2500000
				CPU_SCHED_NUMA_MIGRATE=2
				CPU_NR_MIGRATE=2
			elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
				CPU_BASE_SLICE_NS=2000
				CPU_MIGRATION_COST_NS=5000000
				CPU_SCHED_NUMA_MIGRATE=3
				CPU_NR_MIGRATE=2
			else
				CPU_BASE_SLICE_NS=4000
				CPU_MIGRATION_COST_NS=5000000
				CPU_SCHED_NUMA_MIGRATE=4
				CPU_NR_MIGRATE=2
			fi
		elif [[ $CPU_CLASS == "high" ]]; then
			if [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
				CPU_BASE_SLICE_NS=500
				CPU_MIGRATION_COST_NS=1500000
				CPU_SCHED_NUMA_MIGRATE=1
				CPU_NR_MIGRATE=2
			elif [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]]; then
				CPU_BASE_SLICE_NS=1000
				CPU_MIGRATION_COST_NS=2500000
				CPU_SCHED_NUMA_MIGRATE=2
				CPU_NR_MIGRATE=2
			else
				CPU_BASE_SLICE_NS=2000
				CPU_MIGRATION_COST_NS=2500000
				CPU_SCHED_NUMA_MIGRATE=2
				CPU_NR_MIGRATE=2
			fi
		fi
	elif [[ "$CPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
		if [[ $CPU_CLASS == "verylow" ]]; then
			CPU_BASE_SLICE_NS=10000000
			CPU_MIGRATION_COST_NS=5000000000
			CPU_SCHED_NUMA_MIGRATE=256
			CPU_NR_MIGRATE=1
		elif [[ $CPU_CLASS == "low" ]]; then
			CPU_BASE_SLICE_NS=12500000
			CPU_MIGRATION_COST_NS=1000000000
			CPU_SCHED_NUMA_MIGRATE=128
			CPU_NR_MIGRATE=2
		elif [[ $CPU_CLASS == "mid" ]]; then
			CPU_BASE_SLICE_NS=15000000
			CPU_MIGRATION_COST_NS=50000000
			CPU_SCHED_NUMA_MIGRATE=64
			CPU_NR_MIGRATE=4
		elif [[ $CPU_CLASS == "high" ]]; then
			CPU_BASE_SLICE_NS=20000000
			CPU_MIGRATION_COST_NS=25000000
			CPU_SCHED_NUMA_MIGRATE=32
			CPU_NR_MIGRATE=8
		fi
	fi
	cpu_scheduler_optimizations_apply_values
}

cpu_performance_optimizations_apply_values(){

	if [[ "$CPU_POWER_CONTROL" != "" ]]; then
		echo $CPU_POWER_CONTROL | tee "$CPU_PATH/power/control"
	fi

	if [[ "$CPU_POWER_ASYNC" != "" ]]; then
		echo $CPU_POWER_ASYNC | tee "$CPU_PATH/power/async"
	fi

	for ((i=0; i<CPU_THREADS; i++)); do
	    CPU_DIR="$CPU_PATH/cpu$i"

		if [[ "$CPU_POWER_CONTROL" != "" ]]; then
			echo $CPU_POWER_CONTROL | tee "$CPU_DIR/power/control"
		fi

		if [[ "$CPU_POWER_ASYNC" != "" ]]; then
			echo $CPU_POWER_ASYNC | tee "$CPU_DIR/power/async"
		fi

		if [[ "$CPU_GOVERNOR" != "" ]]; then
	    	echo "$CPU_GOVERNOR" | tee "$CPU_DIR/cpufreq/scaling_governor"
		fi

		if [[ "$CPU_ENERGY_PERFORMANCE_PREFERENCE" != "" ]]; then
	    	echo "$CPU_ENERGY_PERFORMANCE_PREFERENCE" | tee "$CPU_DIR/cpufreq/energy_performance_preference"
		fi
		
	done

}

cpu_performance_optimizations(){

	################################################################
	#VARIABLE INITIALIZATION:

	CPU_POWER_CONTROL=""
	CPU_POWER_ASYNC=""
	CPU_GOVERNOR=""
	CPU_ENERGY_PERFORMANCE_PREFERENCE=""

	################################################################

	if [[ $CPU_CLASS == "verylow" ]]; then
		CPU_POWER_CONTROL="auto"
	else
		CPU_POWER_CONTROL="on"
	fi
	
	if [[ $OPTIMIZATION_PROFILE_USECASE == "server" ]]; then
		CPU_POWER_ASYNC="enabled"
    else
		CPU_POWER_ASYNC="disabled"
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
	cpu_performance_optimizations_apply_values

}

cpu_frequency_optimizations_apply_values(){

	for ((i=0; i<CPU_THREADS; i++)); do
		CPU_DIR="$CPU_PATH/cpu$i"
    	echo $CPU_MAX_PERF | tee $CPU_DIR/cpufreq/scaling_max_freq
    	echo $CPU_MIN_PERF | tee $CPU_DIR/cpufreq/scaling_min_freq
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
	cpu_frequency_optimizations_apply_values
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