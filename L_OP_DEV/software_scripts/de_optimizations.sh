#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP (OPTIMIZATIONS)
source ./utility_scripts/script_directories.sh
source $SAVED_OPTIMIZATION_GOALS
source $SAVED_CPU_DATA
source $SAVED_GPU_DATA
source $SAVED_RAM_DATA
source $SAVED_ROOT_STORAGE_DATA
source $SAVED_OS_DATA
source $SAVED_DE_DATA
##################################################################

#export DISPLAY=:0
#export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
export DE_CONFIG_CHANGED="false"

if [[ $XFCE_INSTALLED == "true" ]]; then

    if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then

        if [[ $XFCE_COMPOSITING_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/use_compositing -s false
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_WRAP_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/wrap_workspaces -s false
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_ANIMATIONS_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/cycle_preview -s false
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_DOCK_SHADOW_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/show_dock_shadow -s false
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_FRAME_SHADOW_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/show_frame_shadow -s false
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_POPUP_SHADOW_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/show_popup_shadow -s false
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/zoom_desktop -s false
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_ZOOM_POINTER_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/zoom_pointer -s false
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_CYCLE_DRAW_FRAME_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/zoom_pointer -s false
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_FOCUS_HINT_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/focus_hint -s false
            export DE_CONFIG_CHANGED="true"
        fi

    elif [[ $CPU_CLASS == "mid" || $CPU_CLASS == "high" ]]; then

        if [[ $XFCE_COMPOSITING_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/use_compositing -s true
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_WRAP_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/wrap_workspaces -s true
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_ANIMATIONS_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/cycle_preview -s true
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_DOCK_SHADOW_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/show_dock_shadow -s true
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_FRAME_SHADOW_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/show_frame_shadow -s true
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_POPUP_SHADOW_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/show_popup_shadow -s true
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/zoom_desktop -s true
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_WORKSPACE_ZOOM_POINTER_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/zoom_pointer -s true
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_CYCLE_DRAW_FRAME_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/zoom_pointer -s true
            export DE_CONFIG_CHANGED="true"
        fi

        if [[ $XFCE_FOCUS_HINT_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/focus_hint -s true
            export DE_CONFIG_CHANGED="true"
        fi

    else
        echo "ERROR WITH XFCE OPTIMIZATION: ERROR DETECTING CPU_CLASS, SKIPPING"
    fi

fi

if [[ $GNOME_INSTALLED == "true" ]]; then

    if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then

        if [[ $GNOME_ANIMATIONS_ENABLED == "true" ]]; then
            runuser -u "$SYSTEM_USER" -- gsettings set org.gnome.desktop.interface enable-animations false
            export DE_CONFIG_CHANGED="true"
        fi

    elif [[ $CPU_CLASS == "mid" || $CPU_CLASS == "high" ]]; then

        if [[ $GNOME_ANIMATIONS_ENABLED == "false" ]]; then
            runuser -u "$SYSTEM_USER" -- gsettings set org.gnome.desktop.interface enable-animations true
            export DE_CONFIG_CHANGED="true"
        fi

    else
        echo "ERROR WITH GNOME OPTIMIZATION: ERROR DETECTING CPU_CLASS, SKIPPING"
    fi

    if [[ $GNOME_TRACKER_ENABLED == "true" ]]; then
        systemctl --user disable --now tracker-miner-fs-3.service
        GNOME_TRACKER_ACTIVE="false"
        export DE_CONFIG_CHANGED="true"
    fi

    if [[ $GNOME_TRACKER_ACTIVE == "true" ]]; then
        systemctl --user disable --now tracker-miner-fs-3.service
        GNOME_TRACKER_ENABLED="false"
        export DE_CONFIG_CHANGED="true"
    fi

fi

if [[ $DE_CONFIG_CHANGED == "true" ]]; then
    $DE_ANALYSIS
fi
