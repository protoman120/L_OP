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

script_create_systemd_service(){
	tee $SCRIPT_L_OP_SERVICE > /dev/null <<EOF
	[Unit]
	Description=Applies L_OP Optimizations 
	After=systemd-modules-load.service

	[Service]
	Type=oneshot
	WorkingDirectory=$L_OP_DIR
	ExecStart=$L_OP_DIR/$SCRIPT_NAME_BASE.sh apply_optimizations
	RemainAfterExit=true

	[Install]
	WantedBy=multi-user.target
EOF
#EOF MUST BE PLACED ON THE SIDE
}

script_create_user_systemd_service(){
	tee $SCRIPT_L_OP_USER_SERVICE > /dev/null <<EOF
	[Unit]
	Description=Applies L_OP Optimizations (After User Login)
	After=graphical-session.target

	[Service]
	Type=oneshot
	WorkingDirectory=$L_OP_DIR
	ExecStart=$L_OP_DIR/$SCRIPT_NAME_BASE.sh apply_user_optimizations
	RemainAfterExit=true

	[Install]
	WantedBy=default.target
EOF
#EOF MUST BE PLACED ON THE SIDE
}


script_enable_systemd_service(){
	 systemctl daemon-reload
 	 systemctl enable "$SCRIPT_SERVICE_NAME"
}

script_enable_user_systemd_service(){
	 systemctl daemon-reload
 	 systemctl enable "$SCRIPT_SERVICE_NAME_USER"
}

script_create_systemd_service
script_enable_systemd_service
script_create_user_systemd_service
script_enable_user_systemd_service