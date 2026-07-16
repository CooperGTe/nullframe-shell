import QtQuick
import Quickshell

import qs.modules.panel.bar
import qs.modules.panel.dock
import qs.modules.panel.controlpanel
import qs.modules.panel.launcher
import qs.modules.powerMenu
import qs.modules.panel

import qs.services
import qs.config
import qs.modules

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

        // Launcher Helper  ------------
        Connections {
            target: Global.get(scope.modelData)

            function onLauncherVisibilityChanged() {
                console.log(Global.get(scope.modelData).launcherVisibility, "glboal")
                if (Global.get(scope.modelData).launcherVisibility) {
                    launcherClose.stop()
                    launcher.active = true
                    launcher.item.visibility = true
                } else {
                    launcherClose.restart()
                    launcher.item.visibility = false
                    launcher.item.allowUngrab = false
                }
            }
        }

        // POWER MENU ? ----------------
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
                if (scope.modelData.name === Hyprland.focusedMonitor) {
                    Global.get(scope.modelData).launcherVisibility = !Global.get(scope.modelData).launcherVisibility
                }
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
        Exclusion {
            exclusion: (!scope.barHug && Config.bar.floating) ? Config.barTotalWidth + 5 : Config.barTotalWidth
            screen: scope.modelData
        }

        Dock {
            id: dock
            //launcherVisible: scope.launcherVisible
            screen: scope.modelData
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
            id: launcherClose
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
                    item.visibility = false
                }
                Global.get(scope.modelData).hideLyrics = launcher.active
            }
        }
    }
}

