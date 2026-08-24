#!/bin/bash

##################################################################
#IMPORTANT: SCRIPT DIRS SETUP
source ./utility_scripts/script_directories.sh
##################################################################

de_save_data(){

    cat > "$SAVED_DE_DATA" <<EOF

    export DISPLAY=$(printf '%q' "$DISPLAY")
    export USER_ID=$(printf '%q' "$USER_ID")
    export DBUS_SESSION_BUS_ADDRESS=$(printf '%q' "$DBUS_SESSION_BUS_ADDRESS")

    #XFCE
    export XFCE_INSTALLED=$(printf '%q' "$XFCE_INSTALLED")
    export XFCE_COMPOSITING_ENABLED=$(printf '%q' "$XFCE_COMPOSITING_ENABLED")
    export XFCE_WORKSPACE_WRAP_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_WRAP_ENABLED")
    export XFCE_WORKSPACE_ANIMATIONS_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_ANIMATIONS_ENABLED")
    export XFCE_WORKSPACE_CYCLE_PREVIEW_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_CYCLE_PREVIEW_ENABLED")
    export XFCE_WORKSPACE_DOCK_SHADOW_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_DOCK_SHADOW_ENABLED")
    export XFCE_WORKSPACE_FRAME_SHADOW_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_FRAME_SHADOW_ENABLED")
    export XFCE_WORKSPACE_POPUP_SHADOW_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_POPUP_SHADOW_ENABLED")
    export XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED")
    export XFCE_WORKSPACE_ZOOM_POINTER_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_ZOOM_POINTER_ENABLED")
    export XFCE_CYCLE_DRAW_FRAME_ENABLED=$(printf '%q' "$XFCE_CYCLE_DRAW_FRAME_ENABLED")
    export XFCE_FOCUS_HINT_ENABLED=$(printf '%q' "$XFCE_FOCUS_HINT_ENABLED")

    #CINNAMON
    export CINNAMON_INSTALLED=$(printf '%q' "$CINNAMON_INSTALLED")
    export CINNAMON_ANIMATIONS_ENABLED=$(printf '%q' "$CINNAMON_ANIMATIONS_ENABLED")

    #GNOME
    export GNOME_INSTALLED=$(printf '%q' "$GNOME_INSTALLED")
    export GNOME_ANIMATIONS_ENABLED=$(printf '%q' "$GNOME_ANIMATIONS_ENABLED")
    export GNOME_TRACKER_ENABLED=$(printf '%q' "$GNOME_TRACKER_ENABLED")
EOF

}

export DISPLAY=$(runuser -u "$SYSTEM_USER" -- printenv DISPLAY)
export USER_ID=$(id -u "$SYSTEM_USER")
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"

if command -v xfwm4 >/dev/null 2>&1; then
    XFCE_INSTALLED="true"

    XFCE_COMPOSITING_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/use_compositing)"
    XFCE_WORKSPACE_WRAP_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/wrap_workspaces)"
    XFCE_WORKSPACE_CYCLE_PREVIEW_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/cycle_preview)"
    XFCE_WORKSPACE_DOCK_SHADOW_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/show_dock_shadow)"
    XFCE_WORKSPACE_FRAME_SHADOW_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/show_frame_shadow)"
    XFCE_WORKSPACE_POPUP_SHADOW_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/show_popup_shadow)"
    XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/zoom_desktop)"
    XFCE_WORKSPACE_ZOOM_POINTER_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/zoom_pointer)"
    XFCE_CYCLE_DRAW_FRAME_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/cycle_draw_frame)"
    XFCE_FOCUS_HINT_ENABLED="$(runuser -u "$SYSTEM_USER" -- xfconf-query -c xfwm4 -p /general/focus_hint)"

else
    XFCE_INSTALLED="false"
fi

if command -v cinnamon >/dev/null 2>&1; then
    CINNAMON_INSTALLED="true"
    CINNAMON_ANIMATIONS_ENABLED="$(runuser -u "$SYSTEM_USER" -- gsettings get org.cinnamon.desktop.interface enable-animations)"
elif command -v cinnamon-session >/dev/null 2>&1; then
    CINNAMON_INSTALLED="true"
    
else
    CINNAMON_INSTALLED="false"
fi

if command -v plasmashell >/dev/null 2>&1; then
    KDE_INSTALLED="true"
else
    KDE_INSTALLED="false"
fi

if command -v gnome-shell >/dev/null 2>&1; then
    GNOME_INSTALLED="true"
    GNOME_ANIMATIONS_ENABLED="$(runuser -u "$SYSTEM_USER" -- gsettings get org.gnome.desktop.interface enable-animations)"
    GNOME_TRACKER_ENABLED="$(systemctl --user is-enabled tracker-miner-fs-3.service 2>/dev/null)"
    GNOME_TRACKER_ACTIVE="$(systemctl --user is-active tracker-miner-fs-3.service 2>/dev/null)"
else
    GNOME_INSTALLED="false"
fi

de_save_data