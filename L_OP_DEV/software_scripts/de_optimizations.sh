#!/bin/bash

#export DISPLAY=:0
#export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
export DE_CONFIG_CHANGED="false"

if [[ "$DEBUG_MODE" == "true" ]]; then
    echo "DEOPTIMIZATIONSDEBUG: OPTIMIZATION_DE_ENABLED = $OPTIMIZATION_DE_ENABLED"
    echo "DEOPTIMIZATIONSDEBUG: CURRENT_CPU_MODEL = $CURRENT_CPU_MODEL"
    echo "DEOPTIMIZATIONSDEBUG: CPU_MODEL = $CPU_MODEL"
    echo "DEOPTIMIZATIONSDEBUG: CPU_CLASS = $CPU_CLASS"
    echo "DEOPTIMIZATIONSDEBUG: CURRENT_RAM_KB = $CURRENT_RAM_KB"
    echo "DEOPTIMIZATIONSDEBUG: RAM_KB = $RAM_KB"
    
    echo "DEOPTIMIZATIONSDEBUG: XFCE_INSTALLED = $XFCE_INSTALLED"        
    echo "DEOPTIMIZATIONSDEBUG: XFCE_COMPOSITING_ENABLED = $XFCE_COMPOSITING_ENABLED"
    echo "DEOPTIMIZATIONSDEBUG: XFCE_WORKSPACE_ANIMATIONS_ENABLED = $XFCE_WORKSPACE_ANIMATIONS_ENABLED"
    echo "DEOPTIMIZATIONSDEBUG: XFCE_WORKSPACE_DOCK_SHADOW_ENABLED = $XFCE_WORKSPACE_DOCK_SHADOW_ENABLED"
    echo "DEOPTIMIZATIONSDEBUG: XFCE_WORKSPACE_FRAME_SHADOW_ENABLED = $XFCE_WORKSPACE_FRAME_SHADOW_ENABLED"
    echo "DEOPTIMIZATIONSDEBUG: XFCE_WORKSPACE_POPUP_SHADOW_ENABLED = $XFCE_WORKSPACE_POPUP_SHADOW_ENABLED"
    echo "DEOPTIMIZATIONSDEBUG: XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED = $XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED"
    echo "DEOPTIMIZATIONSDEBUG: XFCE_WORKSPACE_ZOOM_POINTER_ENABLED = $XFCE_WORKSPACE_ZOOM_POINTER_ENABLED"
    echo "DEOPTIMIZATIONSDEBUG: XFCE_CYCLE_DRAW_FRAME_ENABLED = $XFCE_CYCLE_DRAW_FRAME_ENABLED"
    echo "DEOPTIMIZATIONSDEBUG: XFCE_FOCUS_HINT_ENABLED = $XFCE_FOCUS_HINT_ENABLED"
fi

if [[ $XFCE_INSTALLED == "true" ]]; then

    XFWM4_CONFIG="/home/$SYSTEM_USER/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"

    if [[ -f "$XFWM4_CONFIG" ]]; then

        if [[ $CPU_CLASS == "verylow" || $CPU_CLASS == "low" ]]; then

            if [[ $XFCE_COMPOSITING_ENABLED == "true" ]]; then
                sed -i 's|\(<property name="use_compositing" type="bool" value="\)[^"]*"|\1false"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_ANIMATIONS_ENABLED == "true" ]]; then
                sed -i 's|\(<property name="wrap_workspaces" type="bool" value="\)[^"]*"|\1false"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_DOCK_SHADOW_ENABLED == "true" ]]; then
                sed -i 's|\(<property name="show_dock_shadow" type="bool" value="\)[^"]*"|\1false"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_FRAME_SHADOW_ENABLED == "true" ]]; then
                sed -i 's|\(<property name="show_frame_shadow" type="bool" value="\)[^"]*"|\1false"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_POPUP_SHADOW_ENABLED == "true" ]]; then
                sed -i 's|\(<property name="show_popup_shadow" type="bool" value="\)[^"]*"|\1false"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED == "true" ]]; then
                sed -i 's|\(<property name="zoom_desktop" type="bool" value="\)[^"]*"|\1false"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_ZOOM_POINTER_ENABLED == "true" ]]; then
                sed -i 's|\(<property name="zoom_pointer" type="bool" value="\)[^"]*"|\1false"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_CYCLE_DRAW_FRAME_ENABLED == "true" ]]; then
                sed -i 's|\(<property name="cycle_draw_frame" type="bool" value="\)[^"]*"|\1false"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_FOCUS_HINT_ENABLED == "true" ]]; then
                sed -i 's|\(<property name="focus_hint" type="bool" value="\)[^"]*"|\1false"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

        elif [[ $CPU_CLASS == "mid" || $CPU_CLASS == "high" ]]; then

            if [[ $XFCE_COMPOSITING_ENABLED == "false" ]]; then
                sed -i 's|\(<property name="use_compositing" type="bool" value="\)[^"]*"|\1true"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_ANIMATIONS_ENABLED == "false" ]]; then
                sed -i 's|\(<property name="wrap_workspaces" type="bool" value="\)[^"]*"|\1true"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_DOCK_SHADOW_ENABLED == "false" ]]; then
                sed -i 's|\(<property name="show_dock_shadow" type="bool" value="\)[^"]*"|\1true"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_FRAME_SHADOW_ENABLED == "false" ]]; then
                sed -i 's|\(<property name="show_frame_shadow" type="bool" value="\)[^"]*"|\1true"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_POPUP_SHADOW_ENABLED == "false" ]]; then
                sed -i 's|\(<property name="show_popup_shadow" type="bool" value="\)[^"]*"|\1true"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_ZOOM_DESKTOP_ENABLED == "false" ]]; then
                sed -i 's|\(<property name="zoom_desktop" type="bool" value="\)[^"]*"|\1true"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_WORKSPACE_ZOOM_POINTER_ENABLED == "false" ]]; then
                sed -i 's|\(<property name="zoom_pointer" type="bool" value="\)[^"]*"|\1true"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_CYCLE_DRAW_FRAME_ENABLED == "false" ]]; then
                sed -i 's|\(<property name="cycle_draw_frame" type="bool" value="\)[^"]*"|\1true"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

            if [[ $XFCE_FOCUS_HINT_ENABLED == "false" ]]; then
                sed -i 's|\(<property name="focus_hint" type="bool" value="\)[^"]*"|\1true"|g' "$XFWM4_CONFIG"
                export DE_CONFIG_CHANGED="true"
            fi

        else
            echo "ERROR WITH XFCE OPTIMIZATION: ERROR DETECTING CPU_CLASS, SKIPPING"
        fi

        chown "$SYSTEM_USER:$SYSTEM_USER" "$XFWM4_CONFIG"
        chmod 644 "$XFWM4_CONFIG"

        if [[ $DE_CONFIG_CHANGED == "true" ]]; then
            de_analysis
        fi
    fi
fi