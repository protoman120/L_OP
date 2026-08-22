#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

tmpfs_caching_remove_systemd_service(){
	 systemctl daemon-reload
	 systemctl disable "$SCRIPT_TMPFS_CAHING_SETUP_SERVICE_NAME"
	 rm $SYSTEM_SYSTEMD_SERVICES/$SCRIPT_TMPFS_CAHING_SETUP_SERVICE_NAME
}

tmpfs_caching_remove_systemd_service