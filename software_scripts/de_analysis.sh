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
    export XFCE_INSTALLED=$(printf '%q' "$XFCE_INSTALLED")
    export XFCE_COMPOSITING_ENABLED=$(printf '%q' "$XFCE_COMPOSITING_ENABLED")
    export XFCE_WORKSPACE_ANIMATIONS_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_ANIMATIONS_ENABLED")
    export XFCE_WORKSPACE_CYCLE_PREVIEW_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_CYCLE_PREVIEW_ENABLED")
    export XFCE_WORKSPACE_DOCK_SHADOW_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_DOCK_SHADOW_ENABLED")
    export XFCE_WORKSPACE_FRAME_SHADOW_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_FRAME_SHADOW_ENABLED")
    export XFCE_WORKSPACE_POPUP_SHADOW_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_POPUP_SHADOW_ENABLED")
    export XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED")
    export XFCE_WORKSPACE_ZOOM_POINTER_ENABLED=$(printf '%q' "$XFCE_WORKSPACE_ZOOM_POINTER_ENABLED")
    export XFCE_CYCLE_DRAW_FRAME_ENABLED=$(printf '%q' "$XFCE_CYCLE_DRAW_FRAME_ENABLED")
    export XFCE_FOCUS_HINT_ENABLED=$(printf '%q' "$XFCE_FOCUS_HINT_ENABLED")
    export CINNAMON_INSTALLED=$(printf '%q' "$CINNAMON_INSTALLED")
    export CINNAMON_ANIMATIONS_ENABLED=$(printf '%q' "$CINNAMON_ANIMATIONS_ENABLED")
    export GNOME_INSTALLED=$(printf '%q' "$GNOME_INSTALLED")
    export GNOME_ANIMATIONS_ENABLED=$(printf '%q' "$GNOME_ANIMATIONS_ENABLED")
    export GNOME_TRACKER_ENABLED=$(printf '%q' "$GNOME_TRACKER_ENABLED")
EOF

}

export DISPLAY=$(runuser -u "$SYSTEM_USER" -- printenv DISPLAY)
export USER_ID=$(id -u "$SYSTEM_USER")
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"

XFWM4_CONFIG="/home/$SYSTEM_USER/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"

if [[ -f "$XFWM4_CONFIG" ]]; then
    XFCE_INSTALLED="true"

    XFCE_COMPOSITING_ENABLED="$(grep 'name="use_compositing"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"
    XFCE_WORKSPACE_ANIMATIONS_ENABLED="$(grep 'name="wrap_workspaces"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"
    XFCE_WORKSPACE_CYCLE_PREVIEW_ENABLED="$(grep 'name="cycle_preview"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"
    XFCE_WORKSPACE_DOCK_SHADOW_ENABLED="$(grep 'name="show_dock_shadow"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"
    XFCE_WORKSPACE_FRAME_SHADOW_ENABLED="$(grep 'name="show_frame_shadow"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"
    XFCE_WORKSPACE_POPUP_SHADOW_ENABLED="$(grep 'name="show_popup_shadow"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"
    XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED="$(grep 'name="zoom_desktop"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"
    XFCE_WORKSPACE_ZOOM_POINTER_ENABLED="$(grep 'name="zoom_pointer"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"
    XFCE_CYCLE_DRAW_FRAME_ENABLED="$(grep 'name="cycle_draw_frame"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"
    XFCE_FOCUS_HINT_ENABLED="$(grep 'name="focus_hint"' "$XFWM4_CONFIG" | sed -n 's/.*value="\([^"]*\)".*/\1/p')"

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
    GNOME_TRACKER_ENABLED="$(runuser -u "$SYSTEM_USER" -- systemctl --user is-enabled tracker-miner-fs-3.service)"
else
    GNOME_INSTALLED="false"
fi

de_save_data