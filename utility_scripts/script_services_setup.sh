#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

script_create_systemd_service(){
	tee $SYSTEM_SYSTEMD_SERVICES/$SCRIPT_SERVICE_NAME > /dev/null <<EOF
	[Unit]
	Description=Applies L_OP Optimizations 
	After=systemd-modules-load.service

	[Service]
	Type=oneshot
	ExecStart=$SCRIPT_INSTALLED_DIR/$SCRIPT_NAME.sh apply_optimizations
	RemainAfterExit=true

	[Install]
	WantedBy=multi-user.target
EOF
#EOF MUST BE PLACED ON THE SIDE
}

script_enable_systemd_service(){
	 systemctl daemon-reload
 	 systemctl enable "$SCRIPT_SERVICE_NAME"
}

script_create_systemd_service
script_enable_systemd_service
