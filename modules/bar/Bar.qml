pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules
import qs.modules.panel

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
        color: "#080812"
        //color: "transparent"
        anchors.fill: parent
        topRightRadius: root.barHug ? 0 : 20
        bottomRightRadius:root.barHug ? 0 :  20
        anchors {
            topMargin: root.barHug ? 0 : 5
            bottomMargin: root.barHug ? 0 : 5
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
            anchors.bottomMargin: root.barHug ? 10 : 20
            Behavior on anchors.bottomMargin {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Rectangle {
                //color: "#12131F"
                color: "#7F1223"
                radius: 30
                border.width: 0
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
