
##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

script_remove_systemd_service(){
	 systemctl daemon-reload
	 systemctl disable "$SCRIPT_SERVICE_NAME"
	 rm $SYSTEM_SYSTEMD_SERVICES/$SCRIPT_SERVICE_NAME
}

script_remove_user_systemd_service(){
	 systemctl daemon-reload
	 systemctl disable "$SCRIPT_SERVICE_NAME_USER"
	 rm $SYSTEM_SYSTEMD_SERVICES/$SCRIPT_SERVICE_NAME_USER
}

script_remove_systemd_service
script_remove_user_systemd_service