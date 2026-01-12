pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

import "components"


PanelWindow {
    id:root
    property var scope
    property var barHug
    property bool sidePanelVisible: false

    WlrLayershell.layer: WlrLayer.Top
    implicitWidth: 40
    color: "transparent"
    anchors {
        top: true
        left: true
        bottom: true
    }
    Rectangle {
        color: Color.base
        //color: "transparent"
        anchors.fill: parent
        topRightRadius: root.barHug ? 0 : 20
        bottomRightRadius:root.barHug ? 0 :  20
        anchors {
            topMargin: root.barHug ? 0 : 5
            bottomMargin: root.barHug ? 0 : 5
        }
        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
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
            anchors.topMargin: root.barHug ? 10 : 20
            Behavior on anchors.topMargin {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            PanelButton{
                id:panelbtn
                onClicked: {
                    scope.sidePanelVisible = !scope.sidePanelVisible
                }
            }
            Tray{}
            ResourceIndicator{
                window:root
            }
        }
        ColumnLayout {
            anchors.centerIn: parent
            Workspaces{}
            Mpris{}
        }
        ColumnLayout {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: root.barHug ? 10 : 20
            Behavior on anchors.bottomMargin {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            ControlsGroup {} 
            Rectangle {
                Layout.bottomMargin: 3
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Layout.fillWidth: true
                implicitHeight: 1
                color: Color.container
            }
            BatteryIndicator{}
            Clock{}
        }
    }
}
