import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Shapes

import qs.modules.bar
import qs.modules.sidepanel
import qs.modules.controlPanel
import qs.modules.powerMenu
import qs.modules.launcher
import qs.modules
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
        property bool sidePanelVisible: false
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

        onControlPanelVisibleChanged: {
            console.log(scope.controlPanelVisible)
            if(!scope.controlPanelVisible) {
                controlPanelHide.restart()
                controlpanel.item.visibility = false
            }
            else {
                controlPanelHide.stop()
                controlpanel.active = true
                controlpanel.item.visibility = true
            }
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
        
        property bool internalSidePanelVisible: bar.sidePanelVisible
        property bool barHug:  Hyprland.hasMaximize || scope.sidePanelVisible || 
        (Config.bar.hug === 0 ? false 
        : (Config.bar.hug === 1 ? Hyprland.hasTiling 
        : (Config.bar.hug === 2 ? Hyprland.occupiedWorkspace 
        : true)))

        Hypr.GlobalShortcut {
            name: "sidepanel"
            onReleased: {
                if (scope.modelData.name === Hyprland.focusedMonitor)
                scope.sidePanelVisible = !scope.sidePanelVisible
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
        Hypr.GlobalShortcut {
            name: "controlpanel"
            onPressed: {
                if (scope.modelData.name === Hyprland.focusedMonitor)
                scope.controlPanelVisible = !scope.controlPanelVisible
            }
        }


        SidePanel {
            id: sidepanel
            barRoot: bar
            scope: scope
            screen: scope.modelData
            sidePanelVisible: scope.sidePanelVisible
        }        
        Bar { 
            id:bar
            screen: scope.modelData
            barHug: scope.barHug
            scope: scope
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
            id: controlpanel
            component: ControlPanel {}
            onActiveChanged: {
                if (active && item && scope) {
                    item.scope = scope
                    item.screen = scope.modelData
                    item.visibility = true
                }
                console.log("controlpanel: " + controlpanel.active)
            }
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

        // panel corner border
        //top left corner
        PanelWindow {
            id: topLeftCorner
            screen: scope.modelData
            implicitWidth: scope.barHug ? scope.cornerRadius : 0
            implicitHeight: scope.barHug ? scope.cornerRadius : 0
            color: "transparent"
            exclusiveZone: 0
            anchors {
                top: true
                left: true
            }
            margins { // not funni square patch
                top: scope.barHug ? 0 : -scope.cornerRadius 
            }
          
            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                strokeWidth: 0
                fillColor: Color.base
                startX: 0
                startY: scope.cornerRadius
                PathArc {
                    x: scope.cornerRadius
                    y: 0
                    radiusX: scope.cornerRadius
                    radiusY: scope.cornerRadius
                    direction: PathArc.Clockwise
                }
                PathLine { x: 0; y: 0 }
                PathLine { x: 0; y: scope.cornerRadius }
                }
            }
        }
        // Bottom-left corner
        PanelWindow {
            id: bottomLeftCorner
            screen: scope.modelData
            implicitWidth: scope.barHug ? scope.cornerRadius : 0
            implicitHeight: scope.barHug ? scope.cornerRadius : 0
            color: "transparent"
            exclusiveZone: 0
            anchors {
                bottom: true
                left: true
            }
            margins { // anim patch
                bottom: scope.barHug ? 0 : -scope.cornerRadius 
            }
            
            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                
                ShapePath {
                    strokeWidth: 0
                    fillColor: Color.base
                    startX: scope.cornerRadius
                    startY: scope.cornerRadius
                    PathArc {
                        x: 0
                        y: 0
                        radiusX: scope.cornerRadius
                        radiusY: scope.cornerRadius
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: 0; y: scope.cornerRadius }
                    PathLine { x: scope.cornerRadius; y: scope.cornerRadius }
                }
            }
        }
        // Top-right corner 
        PanelWindow {
            id: topRightCorner
            screen: scope.modelData
            implicitWidth: scope.barHug ? scope.cornerRadius : 0
            implicitHeight: scope.barHug ? scope.cornerRadius : 0
            color: "transparent"
            exclusiveZone: 0
            anchors {
                top: true
                right: true
            }
            
            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                
                ShapePath {
                    strokeWidth: 0
                    fillColor: Color.base
                    startX: 0
                    startY: 0
                    PathArc {
                        x: scope.cornerRadius
                        y: scope.cornerRadius
                        radiusX: scope.cornerRadius
                        radiusY: scope.cornerRadius
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: scope.cornerRadius; y: 0 }
                    PathLine { x: 0; y: 0 }
                }
            }
        }
        // Bottom-right corner
        PanelWindow {
            id: bottomRightCorner
            screen: scope.modelData
            implicitWidth: scope.barHug ? scope.cornerRadius : 0
            implicitHeight: scope.barHug ? scope.cornerRadius : 0
            color: "transparent"
            exclusiveZone: 0
            anchors {
                bottom: true
                right: true
            }
              
            Shape {
                anchors.fill: parent
                 preferredRendererType: Shape.CurveRenderer
                
                ShapePath {
                    strokeWidth: 0
                    fillColor: Color.base
                    startX: 0
                    startY: scope.cornerRadius
                    PathLine { x: scope.cornerRadius; y: scope.cornerRadius }
                    PathLine { x: scope.cornerRadius; y: 0 }
                    PathArc {
                        x: 0
                        y: scope.cornerRadius  
                        radiusX: scope.cornerRadius
                        radiusY: scope.cornerRadius
                        direction: PathArc.Clockwise
                    }
                }
            }
        }
    }
}

