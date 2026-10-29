
##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

script_remove_systemd_service(){
	 systemctl daemon-reload
	 systemctl disable "$SCRIPT_SERVICE_NAME"
	 rm $SCRIPT_L_OP_SERVICE
}

script_remove_user_systemd_service(){
	 systemctl daemon-reload
	 systemctl disable "$SCRIPT_SERVICE_NAME_USER"
	 rm $SCRIPT_L_OP_USER_SERVICE
}

script_remove_systemd_service
script_remove_user_systemd_service