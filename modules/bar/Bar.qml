import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Shapes
import qs.modules

import "components"

Variants {
    model: Quickshell.screens

    Scope {
        id:scope
        required property var modelData
        property real cornerRadius: 15
        PanelWindow {
            id:root
            
            screen: scope.modelData
            WlrLayershell.layer: WlrLayer.Top
            implicitWidth: 40
            color: "transparent"
            anchors {
                top: true
                left: true
                bottom: true
            }
            Rectangle {
                color: "#080812"
                //color: "transparent"
                anchors.fill: parent
                topRightRadius: Globals.barHug ? 0 : 20
                bottomRightRadius:Globals.barHug ? 0 :  20
                anchors {
                    topMargin: Globals.barHug ? 0 : 5
                    bottomMargin: Globals.barHug ? 0 : 5
                }
                Behavior on topRightRadius {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
                Behavior on bottomRightRadius {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
                Behavior on anchors.topMargin {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
                Behavior on anchors.bottomMargin {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: Globals.barHug ? 10 : 20
                    PanelButton{}
                    Tray{}
                    ResourceIndicator{}
                }
                ColumnLayout {
                    anchors.centerIn: parent
                    Workspaces{}
                    Mpris{}
                }
                ColumnLayout {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: Globals.barHug ? 10 : 20
                    Rectangle {
                        color: "#12131F"
                        //color: "#8c1322"
                        radius: 30
                        border.width: 2
                        border.color: "#22232F"
                        implicitHeight: ctlctl.implicitHeight + 10
                        implicitWidth: 30
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        ColumnLayout {
                            anchors.centerIn:parent
                            id:ctlctl
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing:0
                            Brightness{}
                            Audio{}
                            Network{}
                        }
                    }
                    Rectangle {
                        Layout.bottomMargin: 3
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: "#12131F"
                    }
                    BatteryIndicator{}
                    Clock{}
                }
            }
        }
        //top left corner
        PanelWindow {
            id: topLeftCorner
            screen: scope.modelData
            implicitWidth: Globals.barHug ? cornerRadius : 0
            implicitHeight: Globals.barHug ? cornerRadius : 0
            color: "transparent"
            exclusiveZone: 0
            anchors {
                top: true
                left: true
            }
            margins { // not funni square patch
                top: Globals.barHug ? 0 : -cornerRadius 
            }
          
            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                strokeWidth: 0
                fillColor: "#080812"
                startX: 0
                startY: cornerRadius
                PathArc {
                    x: cornerRadius
                    y: 0
                    radiusX: cornerRadius
                    radiusY: cornerRadius
                    direction: PathArc.Clockwise
                }
                PathLine { x: 0; y: 0 }
                PathLine { x: 0; y: cornerRadius }
                }
            }
        }
        // Bottom-left corner
        PanelWindow {
            id: bottomLeftCorner
            screen: scope.modelData
            implicitWidth: Globals.barHug ? cornerRadius : 0
            implicitHeight: Globals.barHug ? cornerRadius : 0
            color: "transparent"
            exclusiveZone: 0
            anchors {
                bottom: true
                left: true
            }
            margins { // anim patch
                bottom: Globals.barHug ? 0 : -cornerRadius 
            }
            
            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                
                ShapePath {
                    strokeWidth: 0
                    fillColor: "#080812"
                    startX: cornerRadius
                    startY: cornerRadius
                    PathArc {
                        x: 0
                        y: 0
                        radiusX: cornerRadius
                        radiusY: cornerRadius
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: 0; y: cornerRadius }
                    PathLine { x: cornerRadius; y: cornerRadius }
                }
            }
        }

        // Top-right corner 
        PanelWindow {
            id: topRightCorner
            screen: scope.modelData
            implicitWidth: Globals.barHug ? cornerRadius : 0
            implicitHeight: Globals.barHug ? cornerRadius : 0
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
                        x: cornerRadius
                        y: cornerRadius
                        radiusX: cornerRadius
                        radiusY: cornerRadius
                        direction: PathArc.Clockwise
                    }
                    PathLine { x: cornerRadius; y: 0 }
                    PathLine { x: 0; y: 0 }
                }
            }
        }
        // Bottom-right corner
        PanelWindow {
            id: bottomRightCorner
            screen: scope.modelData
            implicitWidth: Globals.barHug ? cornerRadius : 0
            implicitHeight: Globals.barHug ? cornerRadius : 0
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
                    startY: cornerRadius
                    PathLine { x: cornerRadius; y: cornerRadius }
                    PathLine { x: cornerRadius; y: 0 }
                    PathArc {
                        x: 0
                        y: cornerRadius  
                        radiusX: cornerRadius
                        radiusY: cornerRadius
                        direction: PathArc.Clockwise
                    }
                }
            }
        }
    }
}
