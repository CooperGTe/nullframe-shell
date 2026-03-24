import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.modules.panel.bar
import qs.modules.panel.controlpanel
import qs.modules.powerMenu
import qs.modules.launcher
import qs.modules.panel
import qs.services
import qs.config

import Quickshell.Hyprland as Hypr

Variants {
    model: Quickshell.screens

    Scope {
        id:scope
        required property var modelData
        property real cornerRadius: 15

        //visibility state
        property bool controlPanelVisible: false
        property bool powerMenuVisible: false
        property bool launcherVisible: false

        //popup warning state
        property real powerAlert: 2

        //control shit
        onPowerMenuVisibleChanged: {
            if (!scope.powerMenuVisible) {
                powerMenuHide.restart()
                powermenu.item.visibility = false
            }
            else powermenu.active = true
        }

        onPowerAlertChanged: {
            console.log(scope.powerAlert)
            if (powerAlert !== 0) {
                poweralert.active = true
            } else poweralert.active = false
        }
        onLauncherVisibleChanged: {
            launcher.active = !launcher.active
            if (!scope.launcherVisible) {
                launcherHide.restart()
                launcher.item.visibility = false
            }
        }
        
        property bool internalcontrolPanelVisible: bar.controlPanelVisible
        property bool barHug:  Hyprland.hasMaximize || scope.controlPanelVisible || 
        (Config.bar.hug === 0 ? false 
        : (Config.bar.hug === 1 ? Hyprland.hasTiling 
        : (Config.bar.hug === 2 ? Hyprland.occupiedWorkspace 
        : true)))

        Hypr.GlobalShortcut {
            name: "controlpanel"
            onReleased: {
                if (scope.modelData.name === Hyprland.focusedMonitor)
                scope.controlPanelVisible = !scope.controlPanelVisible
            }
        }
        Hypr.GlobalShortcut {
            name: "powermenu"
            onPressed: {
                if (scope.modelData.name === Hyprland.focusedMonitor)
                scope.powerMenuVisible = !scope.powerMenuVisible
            }
        }
        Hypr.GlobalShortcut {
            name: "launcher"
            onPressed: {
                if (scope.modelData.name === Hyprland.focusedMonitor && !scope.launcherVisible)
                scope.launcherVisible = !scope.launcherVisible
            }
        }

        ControlPanel {
            id: controlpanel
            barRoot: bar
            scope: scope
            screen: scope.modelData
            controlPanelVisible: scope.controlPanelVisible
        }

        Border {
            hug: scope.barHug
        }

        Bar { 
            id:bar
            screen: scope.modelData
            barHug: scope.barHug
            scope: scope
        }
        PanelWindow {
            WlrLayershell.layer: WlrLayer.Top
            exclusiveZone: 40

            color: "transparent"

            anchors {
                top: (Config.bar.position === 3) ? false : true
                left: (Config.bar.position === 2) ? false : true
                bottom: (Config.bar.position === 1)? false : true
                right: (Config.bar.position === 0) ? false : true
            }
            mask: Region {}
        }
        Timer {
            id: controlPanelHide
            interval: 500
            running: false
            repeat: false
            onTriggered: controlpanel.active = false
        }
        Timer {
            id: powerMenuHide
            interval: 300
            running: false
            repeat: false
            onTriggered: powermenu.active = false
        }
        Timer {
            id: launcherHide
            interval: 300
            running: false
            repeat: false
            onTriggered: launcher.active = false
        }


        LazyLoader {
            id: powermenu
            component: PowerMenu { }
            onActiveChanged: {
                if (active && item && scope) {
                    item.scope = scope
                    item.screen = scope.modelData
                    item.visibility = true
                }
            }
        }
        LazyLoader {
            id: poweralert
            component: PowerAlert { }
            onActiveChanged: {
                if (active && item && scope) {
                    item.scope = scope
                    item.screen = scope.modelData
                    item.visibility = (scope.PowerAlert !== 0)
                }
            }
        }
        LazyLoader {
            id: launcher
            component: Launcher { }
            onActiveChanged: {
                if (active && item && scope) {
                    item.scope = scope
                    item.screen = scope.modelData
                    item.visibility = true
                }
            }
        }
    }
}

