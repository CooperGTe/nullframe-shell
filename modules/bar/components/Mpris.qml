import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Mpris
import Quickshell
import Quickshell.Io
import qs.services
import qs.modules.common
import qs.modules

Item {
    id:root
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: player.implicitHeight

    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property real position: MprisController.visualPosition

    ColumnLayout {
        id: player
        anchors.centerIn: parent
        spacing: 0

        Rectangle {
            color: "#12131f"
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
                            color: "#DFDFFF"
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
                        colPrimary: "#DFDFFF"
                        colSecondary: "#080812"
                        lineWidth: 2
                        Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                fill: 1
                                icon: activePlayer && activePlayer.isPlaying ? "pause" : "play_arrow"
                                font.pixelSize: activePlayer && activePlayer.isPlaying ? 15 : 18 //size patch
                                color: "#DFDFFF"
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
                            color: "#DFDFFF"
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
                color: "#DFDFFF"
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
