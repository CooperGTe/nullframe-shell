pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell

import qs.config
import qs.components
import qs.modules
import qs.setting.components

LazyLoader {
    id: loader
    active: Global.settingVisibility

    FloatingWindow {
        id:root

        property bool navbarVisibility: true

        minimumSize: Qt.size(200, 50) 
        title: "Nullframe Shell Setting"
        color: Colors.base

        onClosed: Global.settingVisibility = false

        RowLayout {
            anchors.fill:parent

            Rectangle {
                implicitWidth: 180
                Layout.fillHeight:true
                Layout.margins:5
                Layout.leftMargin: root.navbarVisibility ? 5 : -180

                Behavior on Layout.leftMargin { Anim {} }
                color: Colors.surface_container
                radius:10

                border.width: 1
                border.color: Colors.surface_container_highest

                ColumnLayout {
                    anchors.fill:parent
                    anchors.margins:10
                    spacing: 10

                    StyledText {
                        text: "Nullframe Settings"
                        color: Colors.primary
                        font.pixelSize: 14
                    }
                    StyledText {
                        Layout.topMargin: -10
                        text: "v0.0.1-test"
                        surface: 3
                        font.pixelSize: 10
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.outline_variant
                    }
                    StyledText {
                        text: "General"
                    }
                    StyledText {
                        text: "Quick Setting"
                        surface: 2
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.outline_variant
                    }
                    StyledText {
                        text: "Network"
                    }
                    StyledText {
                        text: "Network Status"
                        surface: 2
                    }
                    StyledText {
                        text: "Wifi"
                        surface: 2
                    }
                    StyledText {
                        text: "Bluetooth"
                        surface: 2
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.outline_variant
                    }
                    StyledText {
                        text: "Desktop Shell"
                    }
                    StyledText {
                        text: "Panel"
                        surface: 2
                    }
                    StyledText {
                        text: "Dock"
                        surface: 2
                    }
                    StyledText {
                        text: "Launcher"
                        surface: 2
                    }
                    StyledText {
                        text: "Control Panel"
                        surface: 2
                    }
                    StyledText {
                        text: "Widget Panel"
                        surface: 2
                    }
                    StyledText {
                        text: "Desktop Widget"
                        surface: 2
                    }
                    StyledText {
                        text: "Lyrics"
                        surface: 2
                    }
                    StyledText {
                        text: "Power Menu"
                        surface: 2
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.outline_variant
                    }
                    StyledText {
                        text: "About"
                    }
                    StyledText {
                        text: "My System"
                        surface: 2
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
            ScrollBox {
                Layout.fillWidth:true
                Layout.fillHeight:true

                Item {
                    height: 32
                    Layout.fillWidth:true
                    Row {
                        height:32
                        width:parent.width
                        spacing: 10
                        StyledButton {
                            implicitHeight: 24
                            implicitWidth: 24

                            color: Colors.surface_container
                            radius: 5

                            anchors.verticalCenter: parent.verticalCenter

                            icon: "side_navigation"

                            onClicked: () => { root.navbarVisibility = !root.navbarVisibility }
                        }
                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Quick Setting"
                            color: Colors.primary
                            font.pixelSize:14
                        }
                    }
                    StyledButton {
                        implicitHeight: 24
                        implicitWidth: 24

                        color: Colors.surface_container
                        radius: 24

                        anchors.right:parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        icon: "close"

                        onClicked: () => { Global.settingVisibility = false }
                    }
                }

                SectionBox {
                    SettingSwitch {
                        mainText: "PanelFloat"
                        subText: "change float value on the panel"
                    }
                    SettingSwitch {
                        mainText: "Panel Orientation"
                        subText: "change panel position"
                    }
                    SettingSwitch {
                        mainText: "Panel Margin"
                        subText: "change panel position"
                    }
                    SettingSwitch {
                        mainText: "Panel Hug"
                        subText: "change panel position"
                    }
                }
                SectionBox {
                    SettingSwitch {
                        mainText: "PanelFloat"
                        subText: "change float value on the panel"
                    }
                    SettingSwitch {
                        mainText: "Panel Orientation"
                        subText: "change panel position"
                    }
                    SettingSwitch {
                        mainText: "Panel Margin"
                        subText: "change panel position"
                    }
                    SettingSwitch {
                        mainText: "Panel Hug"
                        subText: "change panel position"
                    }
                }
            }
        }


        component SectionBox: Rectangle {
            default property alias content: layout.children
            Layout.fillWidth: true
            implicitHeight: layout.implicitHeight + (layout.anchors.margins * 2)
            color: Colors.base
            radius: 10 
            ColumnLayout {
                id: layout
                anchors.margins: 10
                anchors.fill: parent
            }
        }
        component Anim: NumberAnimation {
            duration: 400
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        }

    }
}
