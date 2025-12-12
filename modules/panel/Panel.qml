import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Shapes

import qs.modules.bar
import qs.modules.sidepanel
import qs.modules.powerMenu
import qs.modules.launcher
import qs.modules
import qs.services
import qs.configs

import Quickshell.Hyprland as Hypr

Variants {
    model: Quickshell.screens

    Scope {
        id:scope
        required property var modelData
        property real cornerRadius: 15
        property bool sidePanelVisible: false
        property bool powerMenuVisible: false
        property bool launcherVisible: false
        property real powerAlert: 2
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
                launcher.item.visibility = false
            }
        }
        
        property bool internalSidePanelVisible: bar.sidePanelVisible
        property bool barHug:  Hyprland.hasMaximize || scope.sidePanelVisible || Configs.barHug

        Hypr.GlobalShortcut {
            name: "sidepanel"
            onPressed: {
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
            id: powerMenuHide
            interval: 300
            running: false
            repeat: false
            onTriggered: powermenu.active = false
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
                fillColor: "#080812"
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
                    fillColor: "#080812"
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
                    fillColor: "#080812"
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
                    fillColor: "#080812"
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

