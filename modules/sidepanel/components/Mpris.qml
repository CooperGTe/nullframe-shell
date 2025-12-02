import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.services
import qs.modules.common
import qs.modules

ColumnLayout {
    id:root
    Layout.fillHeight:true
    Layout.fillWidth: true
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property real position: MprisController.visualPosition
    function formatTime(val) {
        var totalSec = Math.floor(val);

        var min = Math.floor(totalSec / 60);
        var sec = totalSec % 60;

        return ("0" + min).slice(-2) + "." + ("0" + sec).slice(-2);
    }
    RowLayout {
        Layout.leftMargin:5
        Layout.rightMargin:5
        MaterialIcon {
            icon: "music_video"
            font.pixelSize: 18
            color: "#DFDFFF"
            fill: 0
        }
        Text {
            text: "Media"
            Layout.fillWidth:true
            color: "#dfdfff"
            font.pixelSize:12
            font.bold: true
        }
        Button {
            implicitWidth:sync.implicitWidth + 4
            implicitHeight:sync.implicitHeight
            onClicked: Globals.mprisSync = !Globals.mprisSync
            background: Rectangle {
                color: Globals.mprisSync ? "#dfdfff" : "#12131F"
                radius:20
            }
            MaterialIcon {
                id:sync
                anchors.centerIn:parent
                icon: "sync"
                font.pixelSize: 18
                color: !Globals.mprisSync ? "#dfdfff" : "#12131F"
                fill: 0
            }
        }
        MaterialIcon {
            icon: "lyrics"
            font.pixelSize: 18
            color: "#DFDFFF"
            fill: 0
        }
    }
    ClippingRectangle {
        color: "#12131F"
        radius:20
        implicitHeight: 90
        Layout.fillWidth: true
        Image {
            id:bgimg
            anchors.fill: parent
            source: root.activePlayer?.trackArtUrl ?? ""
            fillMode: Image.PreserveAspectCrop
            cache: true
            layer.enabled: true
            layer.effect: MultiEffect {
                brightness: -0.3
                saturation:-0.2
                contrast: -0.5
                blurEnabled: true
                blurMax: 64
                blur: 1.0
            }
        }
        RowLayout {
            anchors.fill: parent
            ClippingRectangle {
                implicitWidth:80
                implicitHeight:80
                Layout.leftMargin:5
                radius:17
                clip: true
                color: "black"
                Image {
                    anchors.fill: parent
                    source: root.activePlayer?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    cache: true
                }
            }
            ColumnLayout{
                Layout.rightMargin:10
                Text{
                    Layout.alignment:Qt.AlignBottom
                    text:root.activePlayer.trackTitle ?? ""
                    elide: Text.ElideRight
                    Layout.maximumWidth: 190
                    font.pixelSize: 12
                    color:"#DFDFFF"
                    font.bold:true
                }
                Text{
                    Layout.alignment:Qt.AlignTop
                    text:root.activePlayer.trackArtist ?? ""
                    Layout.maximumWidth: 140
                    Layout.topMargin: -5
                    font.pixelSize: 10
                    color:"#8F8F9F"
                }
                RowLayout {
                    spacing: 5
                    Layout.fillWidth:true
                    Layout.alignment:Qt.AlignHCenter
                    Button {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        background: Rectangle { 
                            color: "#12131F" 
                            radius:10
                            opacity:0.5
                        }
                        onClicked: activePlayer.previous()
                        contentItem: Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "repeat_one"
                                font.pixelSize: 20
                                color: "#DFDFFF"
                                fill: 1
                            }
                        }
                    }                        
                    //spacer
                    Item {
                        Layout.fillWidth:true
                    }
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        background: Rectangle { 
                            color: "#12131F" 
                            radius:10
                            opacity:0.5
                        }
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
                        background: Rectangle { 
                            color: "#dfdfdf" 
                            radius:20
                            anchors.fill:parent
                        }

                        contentItem: Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: activePlayer && activePlayer.isPlaying ? "pause" : "play_arrow"
                                font.pixelSize: 20
                                fill: 1
                                color: "#22232F"
                            }
                            property bool hovered: false
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: parent.hovered = true
                                onExited: parent.hovered = false
                                onClicked: activePlayer.togglePlaying();
                            }
                        }
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
                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        background: Rectangle { 
                            color: "#12131F" 
                            radius:10
                            opacity:0.5
                        }
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
                    //spacer
                    Item {
                        Layout.fillWidth:true
                    }
                    Button {
                        Layout.alignment: Qt.AlignRight
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        background: Rectangle { 
                            color: "#12131F" 
                            radius:10
                            opacity:0.5
                        }
                        onClicked: activePlayer.previous()
                        contentItem: Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "shuffle"
                                font.pixelSize: 20
                                color: "#DFDFFF"
                                fill: 1
                            }
                        }
                    }                        
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing:5
                    Text {
                        text: root.formatTime(root.position)
                        color:"#dfdfdf"
                    }
                    Slider {
                        // Stretches to fill all left-over space
                        Layout.fillWidth: true
                        Layout.alignment:Qt.AlignVCenter

                        implicitHeight: 10
                        value: root.position / activePlayer.length
                        onMoved: {
                            activePlayer.position = this.value * activePlayer.length
                            MprisController.visualPosition = this.value * activePlayer.length
                        }
                        handle: Rectangle {
                            color: "transparent"
                        }
                        background: Item {
                             Rectangle {
                                 anchors {
                                     bottom: parent.bottom
                                     top: parent.top
                                     left: parent.left
                                 }
                                 color: "#DFDFFF"

                                 implicitWidth: parent.width * (root.position / activePlayer.length)
                                 radius: 20
                             }
                             Rectangle {
                                 anchors {
                                     top: parent.top
                                     bottom: parent.bottom
                                     right: parent.right
                                 }
                                 color: "#02030F"
                                 opacity:0.5

                                 implicitWidth: parent.width * (1 - (root.position / activePlayer.length)) - 1
                                 radius: 20
                             }
                        }
                        WheelHandler {
                            target: null
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel: (event) => {
                                if (event.angleDelta.y < 0) {
                                    activePlayer.seek(-5) 
                                    MprisController.visualPosition -= 5
                                }
                                else if (event.angleDelta.y > 0) {
                                    activePlayer.seek(+5) 
                                    MprisController.visualPosition += 5
                                }
                            }
                        }
                    }
                    Text {
                        text: root.formatTime(activePlayer.length)
                        color:"#dfdfdf"
                    }
                }
            }
        }
    }
}
