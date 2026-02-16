import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Mpris
import Quickshell
import qs.services
import qs.modules.common
import qs.config

Item {
    id:root
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: !Config.barOrientation ? player.implicitHeight : 40
    implicitWidth: Config.barOrientation ? player.implicitWidth : 40

    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property real position: MprisController.visualPosition

    Loader {
        id: player
        anchors.centerIn: parent
        sourceComponent: Config.barOrientation ? horizontal : vertical
    }
    Component {
        id: vertical
        ColumnLayout {
            spacing: 0

            Rectangle {
                color: Color.container
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                radius: 20
                implicitHeight: musicctl.implicitHeight
                implicitWidth: 30

                ColumnLayout {
                    spacing: 0
                    id: musicctl
                    anchors.fill: parent
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        background: Rectangle { color: "transparent" }
                        padding: 0

                        contentItem: Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "skip_previous"
                                font.pixelSize: 20
                                color: Color.surface
                                fill: parent.hovered ? 1 : 0
                            }
                            property bool hovered: false
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: activePlayer.previous()
                            }
                        }
                    }           
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        background: Rectangle { color: "transparent" }
                        padding: 0

                        contentItem: ClippedFilledCircularProgress {
                            size: 28
                            value: root.position / activePlayer?.length
                            colPrimary: Color.primary
                            colSecondary: Color.container_high
                            lineWidth: 3
                            Item {
                                anchors.fill: parent
                                MaterialIcon {
                                    anchors.centerIn: parent
                                    fill: 1
                                    icon: activePlayer && activePlayer.isPlaying ? "pause" : "play_arrow"
                                    font.pixelSize: activePlayer && activePlayer.isPlaying ? 15 : 18 //size patch
                                    color: Color.surface
                                }
                            }
                        }
                        onClicked: activePlayer.togglePlaying();
                        WheelHandler {
                            target: null
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel: (event) => {
                                if (event.angleDelta.y < 0) {
                                    activePlayer.seek(-5)
                                    MprisController.visualPosition -= 5
                                }
                                else if (event.angleDelta.y > 0) {
                                    activePlayer.seek(5)
                                    MprisController.visualPosition += 5
                                }
                            }
                        }
                    }
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        background: Rectangle { color: "transparent" }
                        padding: 0

                        contentItem: Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "skip_next"
                                font.pixelSize: 20
                                fill: parent.hovered ? 1 : 0
                                color: Color.surface
                            }
                            property bool hovered: false
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: activePlayer.next()
                            }
                        }
                    }
                }
            }
            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                MaterialIcon {
                    anchors.centerIn: parent
                    icon: "music_note"
                    font.pixelSize: 20
                    fill: 1
                    color: Color.secondary
                }
                Layout.alignment: Qt.AlignHCenter
                WheelHandler {
                    target: null
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0)
                        activePlayer.volume -= 0.02
                        else if (event.angleDelta.y > 0)
                        activePlayer.volume += 0.02
                    }
                }
            }
        }
    }
    Component {
        id: horizontal
        RowLayout {
            spacing: 0

            Rectangle {
                color: Color.container
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                radius: 20
                implicitHeight: 30
                implicitWidth: musicctl.implicitWidth

                RowLayout {
                    spacing: 0
                    id: musicctl
                    anchors.fill: parent
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        background: Rectangle { color: "transparent" }
                        padding: 0

                        contentItem: Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "skip_previous"
                                font.pixelSize: 20
                                color: Color.surface
                                fill: parent.hovered ? 1 : 0
                            }
                            property bool hovered: false
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: activePlayer.previous()
                            }
                        }
                    }           
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        background: Rectangle { color: "transparent" }
                        padding: 0

                        contentItem: ClippedFilledCircularProgress {
                            size: 28
                            value: root.position / activePlayer?.length
                            colPrimary: Color.primary
                            colSecondary: Color.container_high
                            lineWidth: 3
                            Item {
                                anchors.fill: parent
                                MaterialIcon {
                                    anchors.centerIn: parent
                                    fill: 1
                                    icon: activePlayer && activePlayer.isPlaying ? "pause" : "play_arrow"
                                    font.pixelSize: activePlayer && activePlayer.isPlaying ? 15 : 18 //size patch
                                    color: Color.surface
                                }
                            }
                        }
                        onClicked: activePlayer.togglePlaying();
                        WheelHandler {
                            target: null
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel: (event) => {
                                if (event.angleDelta.y < 0) {
                                    activePlayer.seek(-5)
                                    MprisController.visualPosition -= 5
                                }
                                else if (event.angleDelta.y > 0) {
                                    activePlayer.seek(5)
                                    MprisController.visualPosition += 5
                                }
                            }
                        }
                    }
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        background: Rectangle { color: "transparent" }
                        padding: 0

                        contentItem: Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "skip_next"
                                font.pixelSize: 20
                                fill: parent.hovered ? 1 : 0
                                color: Color.surface
                            }
                            property bool hovered: false
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: activePlayer.next()
                            }
                        }
                    }
                }
            }
            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                MaterialIcon {
                    anchors.centerIn: parent
                    icon: "music_note"
                    font.pixelSize: 20
                    fill: 1
                    color: Color.secondary
                }
                Layout.alignment: Qt.AlignHCenter
                WheelHandler {
                    target: null
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0)
                        activePlayer.volume -= 0.02
                        else if (event.angleDelta.y > 0)
                        activePlayer.volume += 0.02
                    }
                }
            }
        }
    }
}
