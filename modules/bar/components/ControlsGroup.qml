pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import qs.config
import qs.modules.common
Item {
    id:root
    implicitHeight: !Config.barOrientation ? ctlctl.implicitHeight + 10 : 40
    implicitWidth: Config.barOrientation ? ctlctl.implicitWidth + 10 : 40
    Layout.alignment: Qt.AlignHCenter
    property bool popupVisibility: hover.hovered || popup.hovered

    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    HoverHandler {
        id:hover
        cursorShape: Qt.PointingHandCursor
    }
    StyledRect {
        anchors { 
            leftMargin:!Config.barOrientation ? 5 : 0
            rightMargin:!Config.barOrientation ? 5 : 0
            topMargin:Config.barOrientation ? 5 : 0
            bottomMargin:Config.barOrientation ? 5 : 0
        }

        border.width: 1
        border.color: Color.container_high

        Loader {
            id:ctlctl
            anchors.centerIn:parent
            sourceComponent: Config.barOrientation ? horizontal : vertical 
        }
        //Brightness
        component Brightness: Item {
            Layout.alignment: Config.barOrientation ? Qt.AlignVCenter : Qt.AlignHCenter
            implicitHeight: Config.barOrientation ? 40: 20
            implicitWidth: Config.barOrientation ? 20 : 40
            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    if (event.angleDelta.y < 0)
                    Quickshell.execDetached([
                        "brightnessctl", "s", "1%-"
                    ])
                    else if (event.angleDelta.y > 0)
                    Quickshell.execDetached([
                        "brightnessctl", "s", "+1%"
                    ])
                }
            }
            MaterialIcon {
                icon: "brightness_2"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16
                fill:1
                color: Color.surface
            }
        }
        //Audio
        component Audio: Item {
            Layout.alignment: Config.barOrientation ? Qt.AlignVCenter : Qt.AlignHCenter
            implicitHeight: Config.barOrientation ? 40 : 20
            implicitWidth: Config.barOrientation ? 20 : 40

            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    if (event.angleDelta.y < 0) Pipewire.defaultAudioSink.audio.volume -= 0.01
                    else if (event.angleDelta.y > 0) Pipewire.defaultAudioSink.audio.volume += 0.01
                }
            }

            MaterialIcon {
                icon: "volume_up"
                anchors {
                    horizontalCenter: !Config.barOrientation ? parent.horizontalCenter : undefined
                    verticalCenter: Config.barOrientation ? parent.verticalCenter : undefined
                }
                font.pixelSize: 16
                fill:1
                color: Color.surface
            }
        }
        //Network
        component Network: Item {
            Layout.alignment: Qt.AlignHCenter
            implicitHeight: 20
            implicitWidth:40
            MaterialIcon {
                icon: "network_wifi_3_bar"
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 16
                fill:1
                color: Color.surface
            }
        }
        // vertical variant
        Component {
            id: vertical
            ColumnLayout {
                property alias hover1: hover1.hovered
                property alias hover2: hover2.hovered
                property alias hover3: hover3.hovered
                anchors.centerIn:parent
                anchors.horizontalCenter: parent.horizontalCenter
                spacing:0
                Brightness{
                    HoverHandler {
                        id:hover1
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                Audio{
                    HoverHandler {
                        id:hover2
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                Network {
                    HoverHandler {
                        id:hover3
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
        //horizontal variant
        Component {
            id: horizontal
            RowLayout {
                property alias hover1: hover1.hovered
                property alias hover2: hover2.hovered
                property alias hover3: hover3.hovered
                anchors.verticalCenter: parent.verticalCenter
                spacing:0
                Brightness{
                    HoverHandler {
                        id:hover1
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                Audio{
                    HoverHandler {
                        id:hover2
                        cursorShape: Qt.PointingHandCursor
                    }
                }
                Network {
                    HoverHandler {
                        id:hover3
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
        ControlsPopups {
            id:popup
            parent:root
            function setStack(v) {
                if (v === stack) return
                direction = v > stack
                console.log(direction)
                lastStack = stack
                stack = v
            }

            Connections {
                target: ctlctl.item

                function onHover1Changed() { if (target.hover1) popup.setStack(1) }
                function onHover2Changed() { if (target.hover2) popup.setStack(2) }
                function onHover3Changed() { if (target.hover3) popup.setStack(3) }
            }      
        }
    }
}
