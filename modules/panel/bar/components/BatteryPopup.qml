import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

import qs.config
import qs.services
import qs.components

PopupWindow {
    id:root

    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property int percentage: Battery.percentage * 100
    readonly property real timeToEmpty:Battery.timeToEmpty
    readonly property real timeToFull:Battery.timeToFull
    readonly property real energyRate:Battery.energyRate
    readonly property bool isLow: percentage <= 15 / 100

    property var parent
    property bool visibility: parent.popupVisibility

    property real batteryHealth: Battery.healthSupported ? Battery.healthPercentage : 0

    onVisibilityChanged: {
        althealthcheck.running = true
    }

    Process {
        id: althealthcheck

        running: true
        command: ["bash", "-c", `upower -i $(upower -e | grep BAT) | awk '/capacity:/ {gsub("%","",$2); printf "%.4f\\n", $2/100}'`]
        stdout: StdioCollector {
            onStreamFinished: {
                root.batteryHealth = text.trim()
            }
        }
    }

    Behavior on visibility {
        SequentialAnimation {
            ScriptAction { 
                script: root.visible = true
            }
            PauseAnimation { 
                duration: 400
            }
            ScriptAction { 
                script: if (!visibility) root.visible = false
            }
        }
    }

    anchor.item: parent
    anchor.edges: Edges.Left
    anchor.gravity: Edges.Right
    anchor.margins{
        left: 32
        right: 0

    }

    implicitWidth: 200
    implicitHeight: 150

    visible: false
    color:"transparent"

    function formatTime(sec) {
        var sec_num = parseInt(sec, 10); // don't forget the second param
        var hours   = Math.floor(sec_num / 3600);
        var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        var seconds = sec_num - (hours * 3600) - (minutes * 60);

        if (hours === 0) {
            hours   = "";
        } else if (hours   < 10) {
            hours   = "0"+hours+":";
        } else hours+":"
        if (minutes < 10) {minutes = "0"+minutes;}
        if (seconds < 10) {seconds = "0"+seconds;}
        return `${hours}${minutes}:${seconds}`
    }

    ItemShadow{}

    Rectangle {
        anchors {
            fill:parent
            rightMargin: root.visibility ? 20 : 300
            leftMargin: root.visibility ? 5 : -310
            margins:20
        }

        Behavior on anchors.leftMargin {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Behavior on anchors.rightMargin {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        color: Color.base
        radius:20

        ColumnLayout {
            spacing:5

            anchors.margins:10
            anchors.fill:parent

            RowLayout {
                spacing: 10

                Layout.fillWidth: true
                height: 40

                ClippedFilledCircularProgress {
                    size: 30
                    value: root.percentage / 100
                    colPrimary: Color.primary
                    colSecondary: Color.surface_container
                    lineWidth: 5

                    MaterialIcon {
                        id: boltIcon
                        anchors.centerIn:parent
                        color: Color.secondary
                        fill: 1
                        icon: root.isCharging ? "bolt" : "battery_android_5"
                        font.pixelSize: 16
                    }
                }
                Column {
                    spacing: -5
                    StyledText {
                        text: root.percentage + "%"
                        color: Color.primary
                        font.bold:true
                        font.pixelSize: 20
                    }
                    Text {
                        text: "Est: " 
                            + (root.isCharging ? root.formatTime(root.timeToFull) : root.formatTime(root.timeToEmpty))
                            + (root.isCharging ? " To Full" : " To Empty") 
                        color: Color.outline
                    }
                }
            }
            
            RowLayout {
                spacing: 5
                Layout.fillWidth: true
                Layout.bottomMargin: -5
                MaterialIcon {
                    icon: "pulse_alert"
                    color: Color.secondary
                    font.pixelSize: 16
                }
                StyledText {
                    text: "Battery Health: " + root.batteryHealth * 100 + "%"
                    surface: 3
                }
            }
            SegmentedProgressBar {
                id: health
                value: root.batteryHealth
                Layout.fillWidth:true
                implicitHeight:10
            }
            
            Item { Layout.fillHeight: true }
        }
    }
    component SegmentedProgressBar: Item {
        id: root
        property real value: 0.5
        property int segmentCount: 40
        property real segmentSpacing: 2
        property color filledColor: Color.tertiary
        property color emptyColor: Color.surface_container

        width: 200
        height: 20

        Row {
            anchors.fill: parent
            spacing: root.segmentSpacing

            Repeater {
                model: root.segmentCount

                Rectangle {
                    width: (root.width - (root.segmentCount - 1) * root.segmentSpacing) / root.segmentCount
                    height: parent.height
                    radius: 10
                    color: index < Math.round(root.value * root.segmentCount)
                    ? root.filledColor
                    : root.emptyColor
                }
            }
        }
    }
}
