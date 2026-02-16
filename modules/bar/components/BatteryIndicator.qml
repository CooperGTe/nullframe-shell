import qs.services
import qs.modules.common
import QtQuick
import QtQuick.Layouts
import qs.config

import "./"

Item {
    id: root
    property bool borderless: true
    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= 15 / 100

    property bool popupVisibility: hover.hovered

    implicitWidth: 40
    implicitHeight: batteryProgress.implicitHeight

    Layout.alignment: Qt.AlignHCenter
    ClippedProgressBar {
        id: batteryProgress
        vertical:true
        anchors.centerIn: parent
        value: percentage
        valueBarWidth: Config.barOrientation ? 40 : 24
        valueBarHeight: Config.barOrientation ? 24 : 40
        highlightColor: (isLow && !isCharging) ? "#aa4a5a" : Color.secondary
        trackColor: Color.container_high

        Item {
            anchors.centerIn: parent
            width: batteryProgress.valueBarWidth
            height: batteryProgress.valueBarHeight
            Loader {
                anchors.centerIn: parent
                sourceComponent: Config.barOrientation ? horizontal : vertical
                Component {
                    id: vertical
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0

                        MaterialIcon {
                            id: boltIcon
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: -2
                            Layout.bottomMargin: -2
                            fill: 1
                            icon: isCharging ? "bolt" : "battery_android_5"
                            font.pixelSize: 16
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: batteryProgress.text
                            font.bold: true
                        }
                    }
                }
                Component {
                    id: horizontal
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 0

                        MaterialIcon {
                            id: boltIcon
                            Layout.alignment: Qt.AlignVCenter
                            fill: 1
                            icon: isCharging ? "bolt" : "battery_android_5"
                            font.pixelSize: 16
                        }
                        Text {
                            Layout.alignment: Qt.AlignVCenter
                            text: batteryProgress.text
                            font.bold: true
                        }
                    }
                }
            }
        }
    }
    HoverHandler {
        id:hover
        cursorShape: Qt.PointingHandCursor
    }
    BatteryPopup {
        parent:root
    }
}
