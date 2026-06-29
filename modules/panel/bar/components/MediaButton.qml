pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.components
import qs.config

Button {
    id: root

    property real trigger
    property var parentRoot
    property var media
    property string iconName

    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: 28
    Layout.preferredHeight: 28
    background: Rectangle { color: "transparent" }
    onClicked: if (root.trigger === 2) root.media.togglePlaying() //triggerable when the mouse area is not loaded; when the trigger = 2

    Loader {
        anchors.fill: parent
        sourceComponent: root.trigger === 0 ? mediaBtn1 : 
        (root.trigger === 1 ? mediaBtn1 :
        (root.trigger === 2 ? mediaBtn2 :
        mediaBtn3))
    }
    Component {
        id: mediaBtn1
        Item {
            anchors.fill: parent
            MaterialIcon {
                anchors.centerIn: parent
                icon: root.iconName
                font.pixelSize: 20
                color: Color.on_surface
                fill: parent.hovered ? 1 : 0
            }
            property bool hovered: false
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.hovered = true
                onExited: parent.hovered = false
                onClicked: root.trigger === 0 ? root.media.previous() : root.media.next()
            }
        }
    }

    Component {
        id: mediaBtn2
        Item {
            anchors.fill: parent
            ClippedFilledCircularProgress {
                size: 28
                value: parentRoot.position / root.media.length
                colPrimary: Color.secondary
                colSecondary: Color.on_secondary
                lineWidth: 3
                Item {
                    anchors.fill: parent
                    MaterialIcon {
                        anchors.centerIn: parent
                        fill: 1
                        icon: activePlayer && activePlayer.isPlaying ? "pause" : "play_arrow"
                        font.pixelSize: activePlayer && activePlayer.isPlaying ? 15 : 18 //size patch
                        color: Color.secondary
                    }
                }
            }
            WheelHandler {
                target: null
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    if (event.angleDelta.y < 0) {
                        root.media.seek(-5)
                        MprisController.visualPosition -= 5
                    }
                    else if (event.angleDelta.y > 0) {
                        root.media.seek(5)
                        MprisController.visualPosition += 5
                    }
                }
            }
        }
    }

    Component {
        id: mediaBtn3
        Item {
            anchors.fill: parent
            MaterialIcon {
                anchors.centerIn: parent
                icon: root.iconName
                font.pixelSize: 20
                color: Color.primary
                fill: parent.hovered ? 1 : 0
            }
            WheelHandler {
                target: null
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    if (event.angleDelta.y < 0) {
                        activePlayer.volume -= 0.02
                    }
                    else if (event.angleDelta.y > 0) {
                        activePlayer.volume += 0.02
                    }
                }
            }
        }
    }
}
