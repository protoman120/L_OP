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

gpu_power_optimizations_apply_values(){
    #NOTE: CAUTION IF USED OUTSIDE OF "gpu_power_optimizations()", AS THIS ONLY APPLIES THE VALUES FOR 1 GPU AT A TIME

    if [[ "$GPU_POWER_CONTROL" != "" ]]; then
        echo $GPU_POWER_CONTROL | tee "$GPU_PCI_PATH/power/control"
    fi

    if [[ "$GPU_POWER_ASYNC" != "" ]]; then
        echo $GPU_POWER_ASYNC | tee "$GPU_PCI_PATH/power/async"
    fi

    if [[ "$GPU_VENDOR" == "amd" ]]; then
        if [[ "$GPU_POWER_AMD_DMPM_FORCE_PERFORAMANCE_LEVEL" != "" ]]; then
            echo $GPU_POWER_AMD_DMPM_FORCE_PERFORAMANCE_LEVEL | tee "$GPU_PCI_PATH/power_dpm_force_performance_level"
        fi
    fi

    if [[ "$GPU_CLASS" == "intel" ]]; then
        if [[ "$GPU_DRIVER" == "i915" ]]; then
            if [[ "$GPU_POWER_INTEL_I915_DRIVER_PARAMETERS_ENABLE_FBC" != "" ]]; then
                echo $GPU_POWER_INTEL_I915_DRIVER_PARAMETERS_ENABLE_FBC | tee "/sys/module/i915/parameters/enable_fbc"
            fi

            if [[ "$GPU_POWER_INTEL_I915_DRIVER_PARAMETERS_ENABLE_PSR" != "" ]]; then
                echo $GPU_POWER_INTEL_I915_DRIVER_PARAMETERS_ENABLE_PSR | tee "/sys/module/i915/parameters/enable_psr"
            fi
        fi
    fi
}

gpu_power_optimizations(){

	for GPU_FILE in "$SAVED_GPU_DATA_FOLDER"/card*/$SAVED_GPU_DATA_FILE_NAME; do

        source "$GPU_FILE"

        ################################################################
        #VARIABLE INITIALIZATION:

        #TO AVOID ISSUES WITH MULTIPLE GPUS, THESE VARIABLES ARE RESET FOR EACH DEVICE
        GPU_POWER_CONTROL=""
        GPU_POWER_ASYNC=""
        GPU_POWER_AMD_DMPM_FORCE_PERFORAMANCE_LEVEL=""
        GPU_POWER_INTEL_I915_DRIVER_PARAMETERS_ENABLE_FBC=""
        GPU_POWER_INTEL_I915_DRIVER_PARAMETERS_ENABLE_PSR=""

        ################################################################
	
		if [[ $OPTIMIZATION_PROFILE_USECASE == "desktop" ]] || [[ $OPTIMIZATION_PROFILE_USECASE == "server" ]] || [[ "$GPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
			GPU_POWER_CONTROL="auto"
            GPU_POWER_ASYNC="enabled"
		elif [[ $OPTIMIZATION_PROFILE_USECASE == "gaming" ]]; then
            GPU_POWER_CONTROL="on"
            GPU_POWER_ASYNC="enabled"
		else
            GPU_POWER_CONTROL="auto"
            GPU_POWER_ASYNC="disabled"
		fi
		
		if [[ "$GPU_VENDOR" == "amd" ]]; then
		    if [[ "$GPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
                GPU_POWER_AMD_DMPM_FORCE_PERFORAMANCE_LEVEL="auto"
		    elif [[ "$GPU_OPTIMIZATION_GOAL" == "latency" ]]; then
                GPU_POWER_AMD_DMPM_FORCE_PERFORAMANCE_LEVEL="high"
		    else
                GPU_POWER_AMD_DMPM_FORCE_PERFORAMANCE_LEVEL="auto"
		    fi
		fi
		
		if [[ "$GPU_CLASS" == "intel" ]]; then
	        if [[ "$GPU_DRIVER" == "i915" ]]; then
                GPU_POWER_INTEL_I915_DRIVER_PARAMETERS_ENABLE_FBC=1
                GPU_POWER_INTEL_I915_DRIVER_PARAMETERS_ENABLE_PSR=0
	        fi
		fi
        gpu_power_optimizations_apply_values
	done
}

gpu_performance_optimizations_apply_values() {

    #NOTE: CAUTION IF USED OUTSIDE OF "gpu_performance_optimizations()", AS THIS ONLY APPLIES THE VALUES FOR 1 GPU AT A TIME

    if command -v nvidia-smi >/dev/null 2>&1; then
        if [[ "$GPU_NVIDIA_PERSISTENCE_MODE" != "" ]]; then
            nvidia-smi -pm $GPU_NVIDIA_PERSISTENCE_MODE
        fi
        
        if [[ "$GPU_NVIDIA_NEW_MIN_GPU_CLOCK" != "" ]] && [[ "$GPU_NVIDIA_NEW_MAX_GPU_CLOCK" != "" ]]; then
            nvidia-smi --lock-gpu-clocks=$GPU_NVIDIA_NEW_MIN_GPU_CLOCK,$GPU_NVIDIA_NEW_MAX_GPU_CLOCK
        fi

        if [[ "$GPU_NVIDIA_NEW_GPU_MEM_CLOCK" != "" ]]; then
            nvidia-smi --lock-memory-clocks=$GPU_NVIDIA_NEW_GPU_MEM_CLOCK
        fi
    fi

}

gpu_performance_optimizations() {

    for GPU_FILE in "$SCRIPT_SAVED_GPU_DATA"/card*/$SAVED_GPU_DATA_FILE_NAME; do

        source "$GPU_FILE"

        ################################################################
        #VARIABLE INITIALIZATION:

        #TO AVOID ISSUES WITH MULTIPLE GPUS, THESE VARIABLES ARE RESET FOR EACH DEVICE
        GPU_NVIDIA_PERSISTENCE_MODE=""

        GPU_NVIDIA_NEW_MIN_GPU_CLOCK=""
        GPU_NVIDIA_NEW_MAX_GPU_CLOCK=""
        GPU_NVIDIA_NEW_GPU_MEM_CLOCK=""



        ################################################################

        if [[ "$GPU_VENDOR" == "nvidia" ]]; then
            if command -v nvidia-smi >/dev/null 2>&1; then
            	#pm = Persistence Mode
                GPU_NVIDIA_PERSISTENCE_MODE=1

                GPU_POWER_CAP_W=$GPU_POWER_MAX_LIMIT
                if [[ "$GPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
                    if (( GPU_POWER_CAP_W >= 200 )); then
                        GPU_NVIDIA_NEW_MIN_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 30 / 100 ))
                        GPU_NVIDIA_NEW_MAX_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 80 / 100 ))
                        GPU_NVIDIA_NEW_GPU_MEM_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 80 / 100 ))
                    elif (( GPU_POWER_CAP_W >= 100 )); then
                        GPU_NVIDIA_NEW_MIN_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 40 / 100 ))
                        GPU_NVIDIA_NEW_MAX_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 85 / 100 ))
                        GPU_NVIDIA_NEW_GPU_MEM_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 85 / 100 ))
                    elif (( GPU_POWER_CAP_W >= 40 )); then
                        GPU_NVIDIA_NEW_MIN_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 50 / 100 ))
                        GPU_NVIDIA_NEW_MAX_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 90 / 100 ))
                        GPU_NVIDIA_NEW_GPU_MEM_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 90 / 100 ))
                    fi
                elif [[ "$GPU_OPTIMIZATION_GOAL" == "latency" ]]; then
                	GPU_POWER_CAP_W=$GPU_POWER_MAX_LIMIT
                    if (( GPU_POWER_CAP_W >= 200 )); then
                        GPU_NVIDIA_NEW_MIN_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 25 / 100 ))
                        GPU_NVIDIA_NEW_MAX_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 75 / 100 ))
                        GPU_NVIDIA_NEW_GPU_MEM_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 75 / 100 ))
                    elif (( GPU_POWER_CAP_W >= 100 )); then
                        GPU_NVIDIA_NEW_MIN_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 20 / 100 ))
                        GPU_NVIDIA_NEW_MAX_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 80 / 100 ))
                        GPU_NVIDIA_NEW_GPU_MEM_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 80 / 100 ))
                    elif (( GPU_POWER_CAP_W >= 40 )); then
                        GPU_NVIDIA_NEW_MIN_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 15 / 100 ))
                        GPU_NVIDIA_NEW_MAX_GPU_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 85 / 100 ))
                        GPU_NVIDIA_NEW_GPU_MEM_CLOCK=$(( GPU_MAX_GRAPHICS_CLOCK * 85 / 100 ))
                    fi
                fi
            fi
        fi

        if [[ "$GPU_VENDOR" == "amd" ]]; then
		    if [[ "$GPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
		        echo ""
		    elif [[ "$GPU_OPTIMIZATION_GOAL" == "latency" ]]; then
		        echo ""
		    else
		        echo ""
		    fi
        fi

        if [[ "$GPU_CLASS" == "arc" ]]; then
        	if [[ "$GPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
                	echo ""
        	elif [[ "$GPU_OPTIMIZATION_GOAL" == "latency" ]]; then
                	echo ""
        	fi
        fi

        if [[ "$GPU_CLASS" == "intel" ]]; then
            if [[ "$GPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
                #Lowers IGPU to minimum as it shoudn't be used on servers, the power saved can be used to improve CPU performance
                echo $GPU_FREQ_MIN | tee "$GPU_DRM_PATH/gt/gt0/rps_max_freq_mhz"
            elif [[ "$GPU_OPTIMIZATION_GOAL" == "latency" ]]; then
                #GPU_NEW_MIN_FREQ=$(( GPU_FREQ_MAX * 10 / 100 ))
                #echo $GPU_NEW_MIN_FREQ | tee "$GPU_DRM_PATH/gt/gt0/rps_min_freq_mhz"
                if [[ "$GPU_DRIVER" == "i915" ]]; then
                    #echo 1 | tee "/sys/module/i915/parameters/enable_fbc"
                    #echo 0 | tee "/sys/module/i915/parameters/enable_psr"
                fi
            fi
        fi
        gpu_performance_optimizations_apply_values
    done

}

gpu_auto_power_tuner() {

    for GPU_FILE in "$SCRIPT_SAVED_GPU_DATA"/card*/gpu_saved_data_var.sh; do

        [[ -f "$GPU_FILE" ]] || continue
        source "$GPU_FILE"

        if [[ "$GPU_CLASS" == "nvidia" ]]; then
            command -v nvidia-smi >/dev/null 2>&1 || continue
            nvidia-smi -pm 1

            [[ -z "$GPU_POWER_LIMIT" ]] && continue
            
            GPU_POWER_CAP_W=$GPU_POWER_MAX_LIMIT
            
	    if (( GPU_POWER_CAP_W >= 200 )); then
	    	GPU_NEW_CAP_W=$(( GPU_POWER_CAP_W * 70 / 100 ))
	    elif (( GPU_POWER_CAP_W >= 100 )); then
	    	GPU_NEW_CAP_W=$(( GPU_POWER_CAP_W * 75 / 100 ))
	    elif (( GPU_POWER_CAP_W >= 40 )); then
	    	GPU_NEW_CAP_W=$(( GPU_POWER_CAP_W * 80 / 100 ))
	    else
	        GPU_NEW_CAP_W="$GPU_POWER_LIMIT"
	    fi

            if [[ -n "$GPU_POWER_MIN_LIMIT" ]] && (( GPU_NEW_CAP < GPU_POWER_MIN_LIMIT )); then
                GPU_NEW_CAP_W="$GPU_POWER_MIN_LIMIT"
            fi
	    #pl = power limit
            nvidia-smi -pl "$GPU_NEW_CAP_W"
        fi

        if [[ "$GPU_CLASS" == "radeon" ]]; then

            if [[ -w "$GPU_PCI_PATH/power_dpm_force_performance_level" ]]; then
                echo balanced | tee "$GPU_PCI_PATH/power_dpm_force_performance_level"
            fi

            for POWER_CAP in "$GPU_PCI_PATH"/hwmon/hwmon*/power1_cap; do

                [[ -w "$POWER_CAP" ]] || continue
                [[ -n "$GPU_POWER_CAP" ]] || continue

                if (( GPU_POWER_CAP_W > 200 )); then
                    GPU_NEW_CAP=$(( GPU_POWER_CAP * 85 / 100 ))
                elif (( GPU_POWER_CAP_W > 100 )); then
                    GPU_NEW_CAP=$(( GPU_POWER_CAP * 90 / 100 ))
                else
                    GPU_NEW_CAP=$(( GPU_POWER_CAP * 95 / 100 ))
                fi
                echo $GPU_NEW_CAP | tee "POWER_CAP"
            done
        fi

        if [[ "$GPU_CLASS" == "apu" ]]; then
            echo ""
        fi

        if [[ "$GPU_CLASS" == "arc" ]]; then
            for POWER_CAP in "$GPU_PCI_PATH"/hwmon/hwmon*/power1_cap; do
                [[ -w "$POWER_CAP" ]] || continue
                [[ -n "$GPU_POWER_CAP" ]] || continue
                if (( GPU_POWER_CAP_W > 200 )); then
                    GPU_NEW_CAP=$(( GPU_POWER_CAP * 85 / 100 ))
                elif (( GPU_POWER_CAP_W > 100 )); then
                    GPU_NEW_CAP=$(( GPU_POWER_CAP * 90 / 100 ))
                else
                    GPU_NEW_CAP=$(( GPU_POWER_CAP * 95 / 100 ))
                fi
                echo "$GPU_NEW_CAP" | tee "$POWER_CAP"
            done
        fi

        if [[ "$GPU_CLASS" == "intel" ]]; then
            echo ""
        fi
    done
}

gpu_power_optimizations
if [[ "$GPU_COOLING_OPTIMIZATION" == "enabled" ]]; then
    gpu_performance_optimizations
    gpu_auto_power_tuner
fi