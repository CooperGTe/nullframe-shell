pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import qs.config
import qs.modules.panel.controlpanel.components
import qs.components

PanelWindow {
    id:root

    property var scope
    property var barRoot
    property bool visibility: false

    WlrLayershell.layer: WlrLayer.Top

    margins {
        right:-10
        left: loader.active ? -10 : -320-40-Config.barTotalWidth
        bottom:-10
        top:-10
    }

    //color: "transparent"
    implicitWidth: 320+40 //margin
    exclusiveZone:0

    Behavior on visibility {
        SequentialAnimation {
            ScriptAction { 
                script: {
                    loader.active = true
                }
            }
            PauseAnimation { 
                duration: 400
            }
            ScriptAction { 
                script: if (!root.visibility) {
                    loader.active = false
                }
            }
        }
    }

    anchors {
        top: true
        left: true
        bottom: true
    }

    ItemShadow {}

    Loader {
        id:loader

        active:false
        anchors.fill: parent

        sourceComponent: Rectangle {
            color: Colors.base
            radius:13

            anchors {
                fill: parent
                margins: 10 + Config.bar.borderWidth
                leftMargin: root.visibility ? this.anchors.margins : -parent.width
                rightMargin: root.visibility ? this.anchors.margins : parent.width
            } 
            
            Behavior on anchors.leftMargin { Anim {} }
            Behavior on anchors.rightMargin { Anim {} }

            ColumnLayout {
                anchors.fill:parent
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 20
                anchors.margins:5
                spacing:10
                Profile{
                    id:profile
                    scope:root.scope
                }
                QuickControls{}
                Mpris{}
                Stack {}
            }
        }
    }
    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }
}
