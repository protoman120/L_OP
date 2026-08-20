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

SYSTEM_GRUB_FILE=/etc/default/grub

if command -v grub-mkconfig >/dev/null 2>&1 || command -v update-grub >/dev/null 2>&1; then
    BOOTLOADER_GRUB_INSTALLED="true"
else 
    BOOTLOADER_GRUB_INSTALLED="false"
fi

if [[ $BOOTLOADER_GRUB_INSTALLED == "true" ]];then
    CURRENT_GRUB_ARGS="$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$SYSTEM_GRUB_FILE" | sed 's/^GRUB_CMDLINE_LINUX_DEFAULT="//;s/"$//')"

    #BASELINE ARGUMENTS (FOR STRUCTURE, AND TO PREVENT CRASHES IN CASE A VARIABLE'S VALUE WAS NOT SET AT SOME POINT)
    GRUB_BASE_ARGS="quiet splash"

    GRUB_GENERIC_ARGS="lru_gen=1 btusb.enable_autosuspend=0 usbcore.autosuspend=-1 sched_autogroup_enabled=1 rcu_nocbs=all scsi_mod.use_blk_mq=1 audit=0 nmi_watchdog=0 nosoftlockup mce=0"
    #GRUB_GENERIC_ARGS="lru_gen=1 sched_autogroup_enabled=1 scsi_mod.use_blk_mq=1 audit=0 nmi_watchdog=0"

    GRUB_PREEMPT_MODE="voluntary"
    GRUB_PREEMPT="preempt=${GRUB_PREEMPT_MODE}"

    GRUB_ZSWAP_ALGO="zstd"
    GRUB_ZSWAP_PERCENT=10
    GRUB_ZSWAP_ENABLED=1
    GRUB_ZSWAP="zswap.enabled=${GRUB_ZSWAP_ENABLED} zswap.compressor=${GRUB_ZSWAP_ALGO} zswap.max_pool_percent=${GRUB_ZSWAP_PERCENT}"

    GRUB_ZRAM_DEVICES=1
    GRUB_ZRAM="zram.num_devices=${GRUB_ZRAM_DEVICES}"

    GRUB_CPU_MAX_CSTATE=0
    GRUB_CPU_CSTATE="processor.max_cstate=${GRUB_CPU_MAX_CSTATE}"

    GRUB_TRANSPARENT_HUGEPAGES_AMOUNT=0
    GRUB_TRANSPARENT_HUGEPAGES_MODE="never"
    GRUB_TRANSPARENT_HUGEPAGES="hugepages=${GRUB_TRANSPARENT_HUGEPAGES_AMOUNT} transparent_hugepage=${GRUB_TRANSPARENT_HUGEPAGES_MODE}"

    GRUB_MODULE_BLACKLIST="module_blacklist=xfs,gfs2,ocfs2,nilfs2,amiga_partition,atari_partition,mac_partition,aix_partition,bsd_disklabel,ldm_partition,sgi_partition,sun_partition,ksm,firewire_core,firewire_ohci,nfc,dccp,sctp,rds,tipc,atm,can,irda,phonet,x25,rose,decnet,econet,ax25,netrom,ipx,appletalk,psnap,p8022,p8023,p80211"
        
    GRUB_INTEL_ARGUMENTS="i915.enable_fbc=1 i915.enable_psr=1"
    GRUB_AMD_ARGUMENTS="amd_pstate=active RADV_FORCE_VRS=2x2 RADV_PERFTEST=sam RADV_DEBUG=novrsflatshading RADV_PERFTEST=nggc RADV_PERFTEST=gpl"
    GRUB_NVIDIA_ARGUMENTS="nvidia-drm.modeset=1 NVreg_InitializeSystemMemoryAllocations NVreg_UsePageAttributeTable"

    GRUB_LATENCY_ARGS="nvme.noacpi=1 pcie_aspm=off rcu_nocb_poll skew_tick=1 threadirqs nowatchdog"

    GRUB_THROUGHPUT_ARGS="hugepagesz=2M pcie_aspm=performance"

    #ADDITIONAL ARGUMENTS THAT DON'T FALL INTO A SPECIFIC CATEGORY, MUST ALWAYS BE PLACED AT END TO AVOID CRASHES
    GRUB_EXTRA_ARGS="intel_iommu=on amd_iommu=on iommu=pt"
        
    GRUB_TRANSPARENT_HUGEPAGES_AMOUNT=0

    if [[ "$CPU_CLASS" == "verylow" ]]; then
        GRUB_ZSWAP_ALGO="lz4"
        GRUB_CPU_MAX_CSTATE=1
        if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
            GRUB_PREEMPT_MODE="voluntary"
            GRUB_EXTRA_ARGS+=" nohz=off"
        elif [[ "$CPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
            GRUB_PREEMPT_MODE="voluntary"
            GRUB_EXTRA_ARGS="intel_iommu=on amd_iommu=on iommu=pt"
        fi
    elif [[ "$CPU_CLASS" == "low" ]]; then
        GRUB_ZSWAP_ALGO="lz4"
        GRUB_CPU_MAX_CSTATE=1
        if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
            GRUB_PREEMPT_MODE="voluntary"
            GRUB_EXTRA_ARGS+=" nohz=off"
        elif [[ "$CPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
            GRUB_PREEMPT_MODE="voluntary"
            GRUB_EXTRA_ARGS="intel_iommu=on amd_iommu=on iommu=pt"
        fi
    elif [[ "$CPU_CLASS" == "mid" ]]; then
        GRUB_ZSWAP_ALGO="zstd"
        GRUB_CPU_MAX_CSTATE=0
        if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
            GRUB_PREEMPT_MODE="full"
            GRUB_EXTRA_ARGS+=" nohz=off"
        elif [[ "$CPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
            GRUB_PREEMPT_MODE="voluntary"
            GRUB_EXTRA_ARGS="intel_iommu=on amd_iommu=on iommu=pt"
        fi
    elif [[ "$CPU_CLASS" == "high" ]]; then
        GRUB_ZSWAP_ALGO="zstd"
        GRUB_CPU_MAX_CSTATE=0
        if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
            GRUB_PREEMPT_MODE="full"
            GRUB_EXTRA_ARGS+=" nohz=on"
        elif [[ "$CPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
            GRUB_PREEMPT_MODE="voluntary"
            GRUB_EXTRA_ARGS="intel_iommu=on amd_iommu=on iommu=pt"
        fi
    fi

    if [[ $RAM_CLASS == "verylow" ]]; then
        GRUB_ZSWAP_ENABLED=0
        GRUB_ZSWAP_PERCENT=0
        if [[ "$RAM_OPTIMIZATION_GOAL" == "latency" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="never"
        elif [[ "$RAM_OPTIMIZATION_GOAL" == "throughput" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="madvise"
        fi
    elif [[ $RAM_CLASS == "low" ]]; then
        GRUB_ZSWAP_ENABLED=1
        GRUB_ZSWAP_PERCENT=10
        if [[ "$RAM_OPTIMIZATION_GOAL" == "latency" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="never"
        elif [[ "$RAM_OPTIMIZATION_GOAL" == "throughput" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="madvise"
        fi
    elif [[ $RAM_CLASS == "mid" ]]; then
        GRUB_ZSWAP_ENABLED=1
        GRUB_ZSWAP_PERCENT=15
        if [[ "$RAM_OPTIMIZATION_GOAL" == "latency" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="never"
        elif [[ "$RAM_OPTIMIZATION_GOAL" == "throughput" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="always"
        fi
    elif [[ $RAM_CLASS == "high" ]]; then
        GRUB_ZSWAP_ENABLED=1
        GRUB_ZSWAP_PERCENT=20
        if [[ "$RAM_OPTIMIZATION_GOAL" == "latency" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="madvise"
        elif [[ "$RAM_OPTIMIZATION_GOAL" == "throughput" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="always"
        fi
    elif [[ $RAM_CLASS == "veryhigh" ]]; then
        GRUB_ZSWAP_ENABLED=1
        GRUB_ZSWAP_PERCENT=25
        if [[ "$RAM_OPTIMIZATION_GOAL" == "latency" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="madvise"
        elif [[ "$RAM_OPTIMIZATION_GOAL" == "throughput" ]]; then
            GRUB_TRANSPARENT_HUGEPAGES_MODE="always"
        fi
    fi

    #VARIABLES WHOSE VALUES COULD HAVE BEEN CHANGED FROM BASELINE
    GRUB_PREEMPT="preempt=${GRUB_PREEMPT_MODE}"
    GRUB_ZSWAP="zswap.enabled=${GRUB_ZSWAP_ENABLED} zswap.compressor=${GRUB_ZSWAP_ALGO} zswap.max_pool_percent=${GRUB_ZSWAP_PERCENT}"
    GRUB_CPU_CSTATE="processor.max_cstate=${GRUB_CPU_MAX_CSTATE}"
    GRUB_TRANSPARENT_HUGEPAGES="hugepages=${GRUB_TRANSPARENT_HUGEPAGES_AMOUNT} transparent_hugepage=${GRUB_TRANSPARENT_HUGEPAGES_MODE}"
    
    if [[ "$CPU_OPTIMIZATION_GOAL" == "latency" ]]; then
        BOOTLOADER_NEW_GRUB_ARGS="${GRUB_BASE_ARGS} ${GRUB_GENERIC_ARGS} ${GRUB_ZRAM} ${GRUB_ZSWAP} ${GRUB_PREEMPT} ${GRUB_CPU_CSTATE} ${GRUB_TRANSPARENT_HUGEPAGES} ${GRUB_INTEL_ARGUMENTS} ${GRUB_AMD_ARGUMENTS} ${GRUB_NVIDIA_ARGUMENTS} ${GRUB_LATENCY_ARGS} ${GRUB_EXTRA_ARGS} ${GRUB_MODULE_BLACKLIST}"
    elif [[ "$CPU_OPTIMIZATION_GOAL" == "throughput" ]]; then
        BOOTLOADER_NEW_GRUB_ARGS="${GRUB_BASE_ARGS} ${GRUB_GENERIC_ARGS} ${GRUB_ZRAM} ${GRUB_ZSWAP} ${GRUB_PREEMPT} ${GRUB_CPU_CSTATE} ${GRUB_TRANSPARENT_HUGEPAGES} ${GRUB_INTEL_ARGUMENTS} ${GRUB_AMD_ARGUMENTS} ${GRUB_NVIDIA_ARGUMENTS} ${GRUB_THROUGHPUT_ARGS} ${GRUB_EXTRA_ARGS} ${GRUB_MODULE_BLACKLIST}"
else
    BOOTLOADER_NEW_GRUB_ARGS="${GRUB_BASE_ARGS} ${GRUB_GENERIC_ARGS} ${GRUB_ZRAM} ${GRUB_ZSWAP} ${GRUB_PREEMPT} ${GRUB_CPU_CSTATE} ${GRUB_TRANSPARENT_HUGEPAGES} ${GRUB_INTEL_ARGUMENTS} ${GRUB_AMD_ARGUMENTS} ${GRUB_NVIDIA_ARGUMENTS} ${GRUB_EXTRA_ARGS} ${GRUB_MODULE_BLACKLIST}"
    fi

sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$BOOTLOADER_NEW_GRUB_ARGS\"|" "$SYSTEM_GRUB_FILE"
update-initramfs -u
update-grub
fi

cat > "$SAVED_BOOTLOADER_DATA" <<EOF
    #SYSTEM HARDWARE CLASSIFICATIONS (TO BE USED FOR COMPARISON IN PORTABLE INSTALLS)
    BOOTLOADER_CPU_CLASS=$(printf '%q' "$CPU_CLASS")
    BOOTLOADER_RAM_CLASS=$(printf '%q' "$RAM_CLASS")
    #GRUB BOOTLOADER VARIABLES
    SYSTEM_GRUB_FILE=$(printf '%q' "$SYSTEM_GRUB_FILE")
    BOOTLOADER_GRUB_INSTALLED=$(printf '%q' "$BOOTLOADER_GRUB_INSTALLED")
    GRUB_GENERIC_ARGS=$(printf '%q' "$GRUB_GENERIC_ARGS")
    GRUB_PREEMPT_MODE=$(printf '%q' "$GRUB_PREEMPT_MODE")
    GRUB_PREEMPT=$(printf '%q' "$GRUB_PREEMPT")
    GRUB_ZSWAP_ALGO=$(printf '%q' "$GRUB_ZSWAP_ALGO")
    GRUB_ZSWAP_PERCENT=$(printf '%q' "$GRUB_ZSWAP_PERCENT")
    GRUB_ZSWAP=$(printf '%q' "$GRUB_ZSWAP")
    GRUB_ZRAM=$(printf '%q' "$GRUB_ZRAM")
    GRUB_CPU_MAX_CSTATE=$(printf '%q' "$GRUB_CPU_MAX_CSTATE")
    GRUB_CPU_CSTATE=$(printf '%q' "$GRUB_CPU_CSTATE")
    GRUB_TRANSPARENT_HUGEPAGES_AMOUNT=$(printf '%q' "$GRUB_TRANSPARENT_HUGEPAGES_AMOUNT")
    GRUB_TRANSPARENT_HUGEPAGES_MODE=$(printf '%q' "$GRUB_TRANSPARENT_HUGEPAGES_MODE")
    GRUB_TRANSPARENT_HUGEPAGES=$(printf '%q' "$GRUB_TRANSPARENT_HUGEPAGES")
    GRUB_MODULE_BLACKLIST=$(printf '%q' "$GRUB_MODULE_BLACKLIST")
    GRUB_INTEL_ARGUMENTS=$(printf '%q' "$GRUB_INTEL_ARGUMENTS")
    GRUB_AMD_ARGUMENTS=$(printf '%q' "$GRUB_AMD_ARGUMENTS")
    GRUB_NVIDIA_ARGUMENTS=$(printf '%q' "$GRUB_NVIDIA_ARGUMENTS")
    GRUB_LATENCY_ARGS=$(printf '%q' "$GRUB_LATENCY_ARGS")
    GRUB_EXTRA_ARGS=$(printf '%q' "$GRUB_EXTRA_ARGS")
    SCRIPT_BOOTLOADER_REBOOTED_LAST_TIME=$(printf '%q' "$SCRIPT_BOOTLOADER_REBOOTED_LAST_TIME")
EOF
