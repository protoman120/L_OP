#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

tmpfs_caching_setup_systemd_service(){ 
	tee $SYSTEM_SYSTEMD_SERVICES/$SCRIPT_TMPFS_CAHING_SETUP_SERVICE_NAME > /dev/null <<EOF
	[Unit]
	Description=Applies P120 Linux Optimizer TMPFS caching setup
	After=local-fs.target systemd-user-sessions.service
	Requires=local-fs.target

	[Service]
	Type=oneshot
	ExecStart=$TMPFS_CACHING_SETUP

	[Install]
	WantedBy=multi-user.target
EOF
#EOF MUST BE PLACED ON THE SIDE
}

tmpfs_caching_enable_systemd_service(){
     systemctl daemon-reload
     systemctl enable "$SCRIPT_TMPFS_CAHING_SETUP_SERVICE_NAME"
}

tmpfs_caching_setup_systemd_service
tmpfs_caching_enable_systemd_service