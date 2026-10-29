#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

#TODO: ADD THIS TO MAIN SCRIPT IN INSTALL AND ADD TERMINAL COMMAND SCRIPTS TO SCRIPT DIRECTORIES

if [[ $SCRIPT_DEV_BRANCH == "DEV" ]]; then
    L_OP_DIR=$SCRIPT_INSTALLED_DIR
else
    L_OP_DIR=$SCRIPT_INSTALLED_DIR_RELEASE
fi

lop_command_setup(){ 
	tee $SCRIPT_LOP_COMMAND_FILE > /dev/null <<EOF
	#!/bin/bash
    cd $L_OP_DIR
    $L_OP_DIR/$SCRIPT_NAME_BASE.sh
EOF
#EOF MUST BE PLACED ON THE SIDE
    chmod 755 $SCRIPT_LOP_COMMAND_FILE
}

l_op_command_setup(){ 
	tee $SCRIPT_L_OP_COMMAND_FILE > /dev/null <<EOF
	#!/bin/bash
    cd $L_OP_DIR
    $L_OP_DIR/$SCRIPT_NAME_BASE.sh
EOF
#EOF MUST BE PLACED ON THE SIDE
    chmod 755 $SCRIPT_L_OP_COMMAND_FILE
}

lop_command_setup
l_op_command_setup