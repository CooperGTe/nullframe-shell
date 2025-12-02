pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland as Hypr
import Quickshell.Wayland
import qs.modules
import qs.modules.bar
import qs.services

import "components"

Variants {
    model: Quickshell.screens

    Scope {
        id:scope
        required property var modelData
        
        PanelWindow {
            id:root

            property bool visible: Globals.sidePanelVisible
            property bool anim: false
            onVisibleChanged: { 
                if (Globals.sidePanelVisible) loader.active = true;
                root.anim = Globals.sidePanelVisible
                if (Globals.sidePanelVisible) grab.active = true
                if (!Globals.sidePanelVisible) grab.active = false
            }
            property real wsch: Hyprland.activeWorkspace
            onWschChanged: {
                Globals.sidePanelVisible = false
            }
            
            screen: scope.modelData
            WlrLayershell.layer: WlrLayer.Top
            implicitWidth: 320+40//margin
            exclusiveZone:0

            margins {
                left: root.anim ? -20 : -320-40-40
                right: -20
                bottom: -20
                top: -20
            }


            Behavior on margins.left {
                SequentialAnimation {
                    PauseAnimation { 
                        id:pause
                        duration: (Globals.sidePanelVisible && !Hyprland.hasMaximize) ? 200 : 0
                    }
                    NumberAnimation { 
                        duration: 150; 
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.05, 0.9, 0.1, 1.0]
                    }
                    ScriptAction { 
                        script: if (!Globals.sidePanelVisible) loader.active = false 
                    }
                }
            }

            anchors {
                top: true
                left: true
                bottom: true
            }

            color:"transparent"

            Hypr.HyprlandFocusGrab {
                id: grab
                windows: [ root ]
                onActiveChanged: {
                    if (!grab.active) {
                        Globals.sidePanelVisible = false
                    }
                }
            }
            Connections {
                target: grab
            }
            Item {
                Component.onCompleted: {
                    parent.layer.enabled = true;
                    parent.layer.effect = effectComponent;
                }

                Component {
                    id: effectComponent
                    MultiEffect {
                        shadowEnabled: true
                        shadowOpacity: 1
                        shadowColor: "black"
                        shadowBlur: 1
                        shadowScale: 1
                    }
                }
            }
            Loader {
                id:loader
                active:true
                anchors.fill: parent
                sourceComponent: Rectangle {
                    color: "#080812"
                    radius:13

                    anchors {
                        fill: parent
                        margins: 23
                    }
                    ColumnLayout {
                        anchors.fill:parent
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 20
                        anchors.margins:10
                        spacing:10
                        Profile{}
                        QuickControls{}
                        Mpris{}
                        //filler
                        Item {
                            Layout.fillHeight:true
                        }
                        Date{}
                    }
                }
            }
        }
    }
}
