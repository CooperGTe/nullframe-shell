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
    implicitHeight: 40
    color: "transparent"
    anchors {
        top: (Config.bar.position === 3) ? false : true
        left: (Config.bar.position === 2) ? false : true
        bottom: (Config.bar.position === 1)? false : true
        right: (Config.bar.position === 0) ? false : true
    }
    Component.onCompleted: console.log(Config.bar.position) 
    Rectangle {
        color: Color.base
        //color: "transparent"
        anchors.fill: parent
        topRightRadius: root.barHug ? 0 : 
            ((Config.bar.position === 0 || Config.bar.position === 3) ? 20 : 0 )
        bottomRightRadius:root.barHug ? 0 : 
            ((Config.bar.position === 0 || Config.bar.position === 1) ? 20 : 0 )
        topLeftRadius: root.barHug ? 0 : 
            ((Config.bar.position === 2 || Config.bar.position === 3) ? 20 : 0 )
        bottomLeftRadius:root.barHug ? 0 : 
            ((Config.bar.position === 2 || Config.bar.position === 1) ? 20 : 0 )
        anchors {
            topMargin: root.barHug ? 0 : (!Config.barOrientation ? 5 : 0 )
            bottomMargin: root.barHug ? 0 : (!Config.barOrientation ? 5 : 0 )
            leftMargin: root.barHug ? 0 : (Config.barOrientation ? 5 : 0 )
            rightMargin: root.barHug ? 0 : (Config.barOrientation ? 5 : 0 )
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
        Behavior on topLeftRadius {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on bottomLeftRadius {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on anchors.topMargin {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on anchors.leftMargin {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on anchors.rightMargin {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Loader {
            anchors.fill: parent
            sourceComponent: Config.barOrientation ? horizontalLayout : verticalLayout
        }

        Component {
            id: verticalLayout
            ColumnLayout {
                anchors.fill: parent
                // TOP
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    Layout.topMargin: root.barHug ? 10 : 20
                    Behavior on Layout.topMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    PanelButton {
                        id: panelbtn
                        onClicked: scope.sidePanelVisible = !scope.sidePanelVisible
                    }
                    Tray {}
                    ResourceIndicator { window: root }
                }
                Item { Layout.fillHeight: true }   // spacer
                // CENTER
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Workspaces {}
                    Mpris {}
                }
                Item { Layout.fillHeight: true }   // spacer
                // BOTTOM
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                    Layout.bottomMargin: root.barHug ? 10 : 20
                    Behavior on Layout.bottomMargin {
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
                    BatteryIndicator {}
                    Clock {}
                }
            }
        }
        Component {
            id: horizontalLayout
            RowLayout {
                anchors.fill: parent
                // LEFT
                RowLayout {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.leftMargin: root.barHug ? 10 : 20
                    Behavior on Layout.leftMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    PanelButton {
                        id: panelbtn
                        onClicked: scope.sidePanelVisible = !scope.sidePanelVisible
                    }
                    Tray {}
                    ResourceIndicator { window: root }
                }
                // CENTER
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Workspaces {}
                }
                Item { Layout.fillWidth: true }   // spacer
                // RIGHT
                RowLayout {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.rightMargin: root.barHug ? 10 : 20
                    Behavior on Layout.rightMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    Mpris {}
                    ControlsGroup {}
                    Rectangle {
                        Layout.bottomMargin: 3
                        Layout.leftMargin: 5
                        Layout.rightMargin: 5
                        Layout.fillHeight: true
                        implicitWidth: 1
                        color: Color.container
                    }
                    BatteryIndicator {}
                    Clock {}
                }
            }
        }
    }
}
