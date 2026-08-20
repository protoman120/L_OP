#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

if [[ -e $SAVED_GPU_DATA ]]; then
    echo ""
else
    mkdir -p $SAVED_GPU_DATA_FOLDER
fi


gpu_save_data(){

    SAVED_GPU_DATA_CARD=$SAVED_GPU_DATA_FOLDER/$GPU_DRM_CARD
    mkdir $SAVED_GPU_DATA_CARD
    cat > $SAVED_GPU_DATA_CARD/$SAVED_GPU_DATA_FILE_NAME <<EOF
        export GPU_DRM_CARD="$GPU_DRM_CARD"
        export GPU_DRM_PATH="$GPU_DRM_PATH"
        export GPU_PCI_BDF="$GPU_PCI_BDF"
        export GPU_PCI_PATH="$GPU_PCI_PATH"
        export GPU_VENDOR="$GPU_VENDOR"
        export GPU_TYPE="$GPU_TYPE"
        export GPU_CLASS="$GPU_CLASS"
        export GPU_DRIVER="$GPU_DRIVER"
        export GPU_BOOT_VGA="$GPU_BOOT_VGA"
        export GPU_PCIE_LINK_SPEED="$GPU_PCIE_LINK_SPEED"
        export GPU_PCE_LINK_WIDTH="$GPU_PCIE_LINK_WIDTH"
        export GPU_PCIE_MAX_SPEED="$GPU_PCIE_MAX_SPEED"
        export GPU_PCIE_MAX_WIDTH="$GPU_PCIE_MAX_WIDTH"
        export GPU_VRAM="$GPU_VRAM"
        export GPU_POWER_DRAW="$GPU_POWER_DRAW"
        export GPU_POWER_LIMIT="$GPU_POWER_LIMIT"
        export GPU_POWER_MIN_LIMIT="$GPU_POWER_MIN_LIMIT"
        export GPU_POWER_MAX_LIMIT="$GPU_POWER_MAX_LIMIT"
        export GPU_POWER_AVERAGE="$GPU_POWER_AVERAGE"
        export GPU_POWER_AVERAGE_W="$GPU_POWER_AVERAGE_W"
        export GPU_POWER_CAP="$GPU_POWER_CAP"
        export GPU_POWER_CAP_W="$GPU_POWER_CAP_W"

    #INTEL ONLY:
        export GPU_FREQ_MIN="$GPU_FREQ_MIN"
        export GPU_FREQ_MAX="$GPU_FREQ_MAX"
        export GPU_FREQ_CUR="$GPU_FREQ_CUR"
        export GPU_BUSY_PERCENT="$GPU_BUSY_PERCENT"
        
    #NVIDIA ONLY:
        export GPU_CORE_CLOCK="$GPU_CORE_CLOCK"
        export GPU_MEMORY_CLOCK="$GPU_MEMORY_CLOCK"
        export GPU_SM_CLOCK="$GPU_SM_CLOCK"
        export GPU_MAX_GRAPHICS_CLOCK="$GPU_MAX_GRAPHICS_CLOCK"
        export GPU_MAX_MEMORY_CLOCK="$GPU_MAX_MEMORY_CLOCK"
EOF

}

GPU_COUNT=0

for CARD in /sys/class/drm/card*; do

    [[ -d "$CARD/device" ]] || continue
    GPU_DRM_CARD=$(basename "$CARD")

    # Ignores connectors such as "card1-eDP-1" "card0-HDMI-A-1" "card0-DP-1"
    [[ "$GPU_DRM_CARD" =~ ^card[0-9]+$ ]] || continue
    GPU_COUNT=$((GPU_COUNT + 1))
    GPU_DRM_PATH="$CARD"
    GPU_PCI_PATH=$(readlink -f "$GPU_DRM_PATH/device")
    GPU_PCI_BDF=$(basename "$GPU_PCI_PATH")
    GPU_FILE_DIR=$SCRIPT_SAVED_GPU_DATA/$GPU_DRM_CARD
    GPU_FILE="$GPU_FILE_DIR/gpu_saved_data_var.sh"
    GPU_DEVICE_LINE=$(lspci -s "$GPU_PCI_BDF")
    GPU_DRIVER=$(lspci -k -s "$GPU_PCI_BDF" 2>/dev/null | awk -F: '/Kernel driver in use/ {gsub(/^[ \t]+/, "", $2); print $2; exit}')
    GPU_VENDOR_ID=$(< "$GPU_PCI_PATH/vendor")
    GPU_DEVICE_ID=$(< "$GPU_PCI_PATH/device")
    GPU_BOOT_VGA=$(< "$GPU_PCI_PATH/boot_vga")
    GPU_PCIE_LINK_SPEED=$(< "$GPU_PCI_PATH/current_link_speed")
    GPU_PCIE_LINK_WIDTH=$(< "$GPU_PCI_PATH/current_link_width")
    GPU_PCIE_MAX_SPEED=$(< "$GPU_PCI_PATH/max_link_speed")
    GPU_PCIE_MAX_WIDTH=$(< "$GPU_PCI_PATH/max_link_width")
    
    GPU_VENDOR="unknown"
    case "$GPU_VENDOR_ID" in
        0x8086)
            GPU_VENDOR="intel"
            ;;
        0x1002)
            GPU_VENDOR="amd"
            ;;
        0x10de)
            GPU_VENDOR="nvidia"
            ;;
        *)
            GPU_VENDOR="unknown"
            ;;
    esac

    GPU_TYPE="unknown"
    GPU_CLASS=""
    if [[ "$GPU_VENDOR" == "nvidia" ]]; then
        GPU_TYPE="dgpu"
        GPU_CLASS="nvidia"
    elif [[ "$GPU_VENDOR" == "amd" ]]; then
        GPU_TYPE="unknown"
        GPU_CLASS="radeon"

        if [[ "$CPU_VENDOR_ID" == "AuthenticAMD" ]]; then
            if grep -qiE \
                'Ryzen.*[0-9](U|H|HS|HX|G|GE)([^A-Za-z]|$)|Ryzen.*with Radeon Graphics' \
                <<< "$CPU_MODEL"; then

                GPU_TYPE="igpu"
                GPU_CLASS="apu"
            fi
        fi

        if [[ "$GPU_TYPE" == "unknown" ]]; then
            GPU_TYPE="dgpu"
            GPU_CLASS="radeon"
        fi
    elif [[ "$GPU_VENDOR" == "intel" ]]; then

        if grep -qi "arc" <<< "$GPU_DEVICE_LINE"; then
            GPU_TYPE="dgpu"
            GPU_CLASS="arc"
        else
            GPU_TYPE="igpu"
            GPU_CLASS="intel"
            GPU_DRIVER="i915"
        fi

    fi

    if [[ "$GPU_VENDOR" == "nvidia" ]] && command -v nvidia-smi >/dev/null 2>&1; then
        GPU_VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)
        GPU_POWER_DRAW=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader,nounits)
        GPU_POWER_LIMIT=$(nvidia-smi --query-gpu=power.limit --format=csv,noheader,nounits)
        GPU_POWER_MIN_LIMIT=$(nvidia-smi --query-gpu=power.min_limit --format=csv,noheader,nounits)
        GPU_POWER_MAX_LIMIT=$(nvidia-smi --query-gpu=power.max_limit --format=csv,noheader,nounits)
        GPU_CORE_CLOCK=$(nvidia-smi --query-gpu=clocks.gr --format=csv,noheader,nounits)
        GPU_MEMORY_CLOCK=$(nvidia-smi --query-gpu=clocks.mem --format=csv,noheader,nounits)
        GPU_SM_CLOCK=$(nvidia-smi --query-gpu=clocks.sm --format=csv,noheader,nounits)
        GPU_MAX_GRAPHICS_CLOCK=$(nvidia-smi --query-gpu=clocks.max.graphics --format=csv,noheader,nounits)
        GPU_MAX_MEMORY_CLOCK=$(nvidia-smi --query-gpu=clocks.max.memory --format=csv,noheader,nounits)
    fi

    if [[ "$GPU_VENDOR" == "amd" ]]; then
        GPU_VRAM=$(< "$GPU_PCI_PATH/mem_info_vram_total")
        GPU_POWER_AVERAGE=$(cat "$GPU_PCI_PATH"/hwmon/hwmon*/power1_average | head -1)
        GPU_POWER_CAP=$(cat "$GPU_PCI_PATH"/hwmon/hwmon*/power1_cap | head -1)
        GPU_POWER_AVERAGE_W=$((GPU_POWER_AVERAGE / 1000000))
        GPU_POWER_CAP_W=$((GPU_POWER_CAP / 1000000))
    fi

    if [[ "$GPU_VENDOR" == "intel" ]]; then
        GPU_VRAM="shared"
        GPU_POWER_AVERAGE=$(cat "$GPU_PCI_PATH"/hwmon/hwmon*/power1_average | head -1)
        GPU_POWER_CAP=$(cat "$GPU_PCI_PATH"/hwmon/hwmon*/power1_cap | head -1)
        GPU_POWER_AVERAGE_W=$((GPU_POWER_AVERAGE / 1000000))
        GPU_POWER_CAP_W=$((GPU_POWER_CAP / 1000000))
        GPU_FREQ_MIN=$(< "$GPU_DRM_PATH/gt/gt0/rps_min_freq_mhz")
        GPU_FREQ_MAX=$(< "$GPU_DRM_PATH/gt/gt0/rps_max_freq_mhz")
        GPU_FREQ_CUR=$(< "$GPU_DRM_PATH/gt/gt0/rps_cur_freq_mhz")
        GPU_BUSY_PERCENT=$(< "$GPU_DRM_PATH/gt/gt0/busy_percent")
    fi
    gpu_save_data
done