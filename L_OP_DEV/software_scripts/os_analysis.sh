#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

os_save_data(){

  cat > "$SAVED_OS_DATA" <<EOF
      export SYSTEM_KERNEL_VERSION=$(printf '%q' "$SYSTEM_KERNEL_VERSION")
      export SYSTEM_CURRENT_DISTRO_VERSION=$(printf '%q' "$SYSTEM_CURRENT_DISTRO_VERSION")
      export SYSTEM_DISTRO=$(printf '%q' "$SYSTEM_DISTRO")
      export SYSTEM_DISTRO_BASE_1=$(printf '%q' "$SYSTEM_DISTRO_BASE_1")
      export SYSTEM_DISTRO_BASE_2=$(printf '%q' "$SYSTEM_DISTRO_BASE_2")
      export SYSTEM_VM=$(printf '%q' "$SYSTEM_VM")
      export SYSTEM_VM_VIRTUALIZATION=$(printf '%q' "$SYSTEM_VM_VIRTUALIZATION")
EOF

}

SYSTEM_KERNEL_VERSION=$(uname -r)
SYSTEM_CURRENT_DISTRO_VERSION=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
SYSTEM_DISTRO=$(grep NAME /etc/os-release | cut -d= -f2 | tr -d '"')
SYSTEM_DISTRO_BASE_1=$(. /etc/os-release && set -- $ID_LIKE && echo "$1")
SYSTEM_DISTRO_BASE_2=$(. /etc/os-release && set -- $ID_LIKE && echo "$2")
SYSTEM_SETUP_USER=$SYSTEM_USER
if systemd-detect-virt --quiet; then
    SYSTEM_VM="true"
else
    SYSTEM_VM="false"
fi
SYSTEM_VM_VIRTUALIZATION=$(systemd-detect-virt)

os_save_data