#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

if [[ $SCRIPT_DEV_BRANCH == "DEV" ]]; then
    L_OP_DIR=$SCRIPT_INSTALLED_DIR
	L_OP_NAME=$SCRIPT_NAME
else
    L_OP_DIR=$SCRIPT_INSTALLED_DIR_RELEASE
	L_OP_NAME=$SCRIPT_NAME_RELEASE
fi

tmpfs_caching_setup_systemd_service(){ 
	tee $SYSTEM_SYSTEMD_SERVICES/$SCRIPT_TMPFS_CAHING_SETUP_SERVICE_NAME > /dev/null <<EOF
	[Unit]
	Description=Applies L_OP TMPFS caching setup
	After=local-fs.target systemd-user-sessions.service
	Requires=local-fs.target

	[Service]
	Type=oneshot
	WorkingDirectory=$L_OP_DIR
	ExecStart=$L_OP_DIR/utility_scripts/$TMPFS_CACHING_SETUP_NAME

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