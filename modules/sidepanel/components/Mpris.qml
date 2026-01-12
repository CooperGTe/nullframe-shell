pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.services
import qs.modules.common
import qs.modules
import qs.config

ColumnLayout {
    id:root
    Layout.fillHeight:true
    Layout.fillWidth: true
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property var allPlayer: MprisController.allPlayer
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
            color: Color.surface
            fill: 0
        }
        Text {
            text: "Media"
            Layout.fillWidth:true
            color: Color.surface
            font.pixelSize:12
            font.bold: true
        }
        Button {
            implicitWidth: 60
            implicitHeight:20
            onClicked: Config.showLyrics = !Config.showLyrics
            background: Rectangle {
                color: Config.showLyrics ? Color.surface : Color.container
                radius:20
            }
            RowLayout {
                anchors.fill:parent
                anchors.leftMargin:5
                spacing:0
                MaterialIcon {
                    id:lyrics
                    icon: "lyrics"
                    font.pixelSize: 16
                    Layout.bottomMargin: -2//patch uneven symbol
                    color: !Config.showLyrics ? Color.surface : Color.container
                    fill: 0
                }
                Text {
                    text: "Lyrics"
                    color:  !Config.showLyrics ? Color.surface : Color.container
                    font.pixelSize:10
                    font.bold: true
                }
            }
        }
    }
    ListView {
        Layout.fillHeight:true
        Layout.fillWidth:true
        clip:true

        model: root.allPlayer
        spacing:5
        delegate: ClippingRectangle {
            required property var modelData
            color: Color.container
            radius:20
            implicitHeight: 90
            implicitWidth: parent.width
            Layout.fillWidth: true
            property real visualPosition: 0
            Timer {
                running: modelData.playbackState == MprisPlaybackState.Playing
                interval: 1000
                repeat: true
                onTriggered: { 
                    modelData.positionChanged();
                    playerPosition.running = true
                    //console.log(visualPosition)
                }
            }
            Process {
                id: playerPosition
                running: true

                // dbus-send + parse int64 Position
                command: [
                    "bash", "-c",
                    "dbus-send --print-reply --dest=" + modelData.dbusName +
                    " /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get " +
                    "string:org.mpris.MediaPlayer2.Player string:Position " +
                    " | awk '/int64/ {print $NF}'"
                ]

                stdout: StdioCollector {
                    onStreamFinished: {
                        var ns = parseInt(this.text)     // nanoseconds
                        if (!ns) return

                        var val = ns / 1000000        // seconds

                        if (modelData.canSeek && modelData.positionSupported) {
                            visualPosition = val
                        }
                        //console.log(val)
                    }
                }
            }    
            Connections {
                target: modelData
                onPostTrackChanged: {
                    visualPosition = 0
                }
            }

            Image {
                id:bgimg
                anchors.fill: parent
                source: modelData.trackArtUrl ?? ""
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
                anchors.leftMargin:modelData.trackArtUrl !== "" ? 5 : 15
                ClippingRectangle {
                    implicitWidth:80
                    implicitHeight:80
                    radius:17
                    clip: true
                    color: Color.container_high
                    Image {
                        anchors.fill: parent
                        source: modelData.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                    }
                }
                ColumnLayout{
                    Layout.rightMargin:10
                    Text{
                        Layout.alignment:Qt.AlignBottom
                        text:modelData.trackTitle ?? ""
                        elide: Text.ElideRight
                        Layout.maximumWidth: 190
                        font.pixelSize: 12
                        color:Color.surface
                        font.bold:true
                    }
                    Text{
                        Layout.alignment:Qt.AlignTop
                        text:modelData.trackArtist ?? ""
                        Layout.maximumWidth: 140
                        Layout.topMargin: modelData.trackArtist !== "" ? -5 : -10
                        font.pixelSize: 10
                        color:Color.surface_mid
                    }
                    RowLayout {
                        spacing: 5
                        Layout.fillWidth:true
                        Layout.alignment:Qt.AlignHCenter
                        Button {
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            visible: modelData.shuffleSupported
                            background: Rectangle { 
                                color: Color.container 
                                radius:10
                                opacity:0.5
                            }
                            onClicked: modelData.previous()
                            contentItem: Item {
                                anchors.fill: parent
                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: "repeat_one"
                                    font.pixelSize: 20
                                    color: Color.surface
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
                            visible: modelData.canGoPrevious
                            background: Rectangle { 
                                color: Color.container 
                                radius:10
                                opacity:0.5
                            }
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
                            visible: modelData.canTogglePlaying
                            background: Rectangle { 
                                color: Color.surface
                                radius:20
                                anchors.fill:parent
                            }

                            contentItem: Item {
                                anchors.fill: parent
                                MaterialIcon {
                                    anchors.centerIn: parent
                                    icon: modelData.isPlaying ? "pause" : "play_arrow"
                                    font.pixelSize: 20
                                    fill: 1
                                    color: Color.container_high
                                }
                                property bool hovered: false
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: parent.hovered = true
                                    onExited: parent.hovered = false
                                    onClicked: modelData.togglePlaying();
                                }
                            }
                            WheelHandler {
                                target: null
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                onWheel: (event) => {
                                    if (event.angleDelta.y < 0)
                                    modelData.volume -= 0.02
                                    else if (event.angleDelta.y > 0)
                                    modelData.volume += 0.02
                                }
                            }
                        }
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            visible: modelData.canGoNext
                            background: Rectangle { 
                                color: Color.container 
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
                        //spacer
                        Item {
                            Layout.fillWidth:true
                        }
                        Button {
                            Layout.alignment: Qt.AlignRight
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            visible: modelData.shuffleSupported
                            background: Rectangle { 
                                color: Color.container 
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
                                    color: Color.surface
                                    fill: 1
                                }
                            }
                        }                        
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing:5
                        Text {
                            text: root.formatTime(visualPosition)
                            color:Color.surface
                        }
                        Slider {
                            // Stretches to fill all left-over space
                            Layout.fillWidth: true
                            Layout.alignment:Qt.AlignVCenter

                            implicitHeight: 10
                            onMoved: {
                                modelData.position = this.value * modelData.length
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
                                    color: Color.surface

                                    implicitWidth: parent.width * (visualPosition / modelData.length)
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

                                    implicitWidth: parent.width * (1 - (visualPosition / modelData.length)) - 1
                                    radius: 20
                                }
                            }
                            WheelHandler {
                                target: null
                                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                                onWheel: (event) => {
                                    if (event.angleDelta.y < 0) {
                                        activePlayer.seek(-5) 
                                        visualPosition -= 5
                                    }
                                    else if (event.angleDelta.y > 0) {
                                        activePlayer.seek(+5) 
                                        visualPosition += 5
                                    }
                                }
                            }
                        }
                        Text {
                            text: root.formatTime(modelData.length)
                            color:Color.surface
                        }
                    }
                }
            }
        }
    }
}
