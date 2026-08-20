    #SYSTEM HARDWARE CLASSIFICATIONS (TO BE USED FOR COMPARISON IN PORTABLE INSTALLS)
    BOOTLOADER_CPU_CLASS=high
    BOOTLOADER_RAM_CLASS=high
    #GRUB BOOTLOADER VARIABLES
    SYSTEM_GRUB_FILE=/etc/default/grub
    BOOTLOADER_GRUB_INSTALLED=true
    GRUB_GENERIC_ARGS=lru_gen=1\ btusb.enable_autosuspend=0\ usbcore.autosuspend=-1\ sched_autogroup_enabled=1\ rcu_nocbs=all\ scsi_mod.use_blk_mq=1\ audit=0\ nmi_watchdog=0\ nosoftlockup\ mce=0
    GRUB_PREEMPT_MODE=full
    GRUB_PREEMPT=preempt=full
    GRUB_ZSWAP_ALGO=zstd
    GRUB_ZSWAP_PERCENT=20
    GRUB_ZSWAP=zswap.enabled=1\ zswap.compressor=zstd\ zswap.max_pool_percent=20
    GRUB_ZRAM=zram.num_devices=1
    GRUB_CPU_MAX_CSTATE=0
    GRUB_CPU_CSTATE=processor.max_cstate=0
    GRUB_TRANSPARENT_HUGEPAGES_AMOUNT=0
    GRUB_TRANSPARENT_HUGEPAGES_MODE=madvise
    GRUB_TRANSPARENT_HUGEPAGES=hugepages=0\ transparent_hugepage=madvise
    GRUB_MODULE_BLACKLIST=module_blacklist=xfs\,gfs2\,ocfs2\,nilfs2\,amiga_partition\,atari_partition\,mac_partition\,aix_partition\,bsd_disklabel\,ldm_partition\,sgi_partition\,sun_partition\,ksm\,firewire_core\,firewire_ohci\,nfc\,dccp\,sctp\,rds\,tipc\,atm\,can\,irda\,phonet\,x25\,rose\,decnet\,econet\,ax25\,netrom\,ipx\,appletalk\,psnap\,p8022\,p8023\,p80211
    GRUB_INTEL_ARGUMENTS=i915.enable_fbc=1\ i915.enable_psr=1
    GRUB_AMD_ARGUMENTS=amd_pstate=active\ RADV_FORCE_VRS=2x2\ RADV_PERFTEST=sam\ RADV_DEBUG=novrsflatshading\ RADV_PERFTEST=nggc\ RADV_PERFTEST=gpl
    GRUB_NVIDIA_ARGUMENTS=nvidia-drm.modeset=1\ NVreg_InitializeSystemMemoryAllocations\ NVreg_UsePageAttributeTable
    GRUB_LATENCY_ARGS=nvme.noacpi=1\ pcie_aspm=off\ rcu_nocb_poll\ skew_tick=1\ threadirqs\ nowatchdog
    GRUB_EXTRA_ARGS=intel_iommu=on\ amd_iommu=on\ iommu=pt\ nohz=on
    SCRIPT_BOOTLOADER_REBOOTED_LAST_TIME=''
