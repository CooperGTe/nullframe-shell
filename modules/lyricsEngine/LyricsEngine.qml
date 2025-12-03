pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

import qs.services

Variants {
    model: Quickshell.screens
    Scope {
        id: root
        required property var modelData

        readonly property MprisPlayer activePlayer: MprisController.activePlayer
        readonly property real position: MprisController.visualPosition
        property string lrcRaw: ""
        property var lrcParsed: []
        property string currentLine: ""
        property int offset: 0
        property bool showLyrics: true
        property string artist: root.activePlayer.trackArtist


        FileView {
            id: lrcFile
            printErrors: false
            path: Quickshell.env("HOME") + 
            "/.lyrics/" + 
            root.artist.replace(" feat. ", ", ").replace(" & ", ", ") + //inconsistent artist output patch
            " - " + 
            root.activePlayer.trackTitle + 
            ".lrc"
            onLoaded: {
                root.currentLine = ""; 
                root.lrcParsed = []
                const raw = lrcFile.text()
                root.lrcRaw = raw
                root.lrcParsed = root.parseLrc(raw)
            }
            onLoadFailed: {
                const raw = "";
                root.lrcRaw = raw;
                root.lrcParsed = root.parseLrc(raw);
                root.currentLine = raw;
            }
        }

        function parseLrc(raw) {
            const lines = raw.split("\n")
            let parsed = []
            parsed.push({ time: 0, text: "" }) // 0 second patch
            root.offset = 0;
            for (let line of lines) {
                let matches;
                if ((matches = line.match(/\[(\d+):(\d+)(?:\.(\d+))?\](.*)/))) {
                    let min = parseInt(matches[1]);
                    let sec = parseInt(matches[2]);
                    let ms = parseInt(matches[3] || 0);
                    let text = matches[4].trim();
                    let time = min * 60 + sec + ms / 1000;
                    parsed.push({ time: time, text: text });
                } else if (matches = line.match(/\[offset:([+-]?\d+)\]/)) {
                    root.offset = parseInt(matches[1]);
                }
            }        
            parsed.sort((a, b) => a.time - b.time)
            return parsed
        }

        property real visualPosition: 0
        property real basePosition: 0
        property real lastUpdate: 0

        // DBus updates your real position every 1 second
        Connections {
            target: root.activePlayer
            onPositionChanged: {
                basePosition = root.position
                lastUpdate = Date.now() / 1000
            }
        }

        FrameAnimation {
            running: root.activePlayer.playbackState == MprisPlaybackState.Playing && root.lrcParsed.length > 1
            onTriggered: {
                let now = Date.now() / 1000
                let dt = now - root.lastUpdate

                // interpolate forward at 1x speed
                root.visualPosition = root.basePosition + dt

                // use visualPosition for lyrics
                let pos = root.visualPosition - (root.offset / 1000);
                //console.log(pos)

                for (let i = root.lrcParsed.length - 1; i >= 0; i--) {
                    if (pos >= root.lrcParsed[i].time) {
                        if (root.currentLine !== root.lrcParsed[i].text) {
                            root.currentLine = root.lrcParsed[i].text
                        }
                        break
                    }
                }
            }
        }

        Timer {
            id: hideTimer
            interval: 5000
            onTriggered: root.showLyrics = true
        }
        LazyLoader {
            active: root.showLyrics && (root.modelData.name === Hyprland.focusedMonitor)
            PanelWindow {
                id: winroot
                screen:root.modelData
                WlrLayershell.layer: WlrLayer.Overlay
                exclusiveZone: 0
                color: "transparent"
                //mask: Region {}
                anchors {
                    bottom: true
                }
                margins { bottom: Hyprland.hasMaximize ? 70 : 10 }
                property bool showSubtitle: true
                implicitWidth: root.currentLine != "" ? subtitle.implicitWidth + 20 : 0
                implicitHeight: subtitle.implicitHeight
                Rectangle {
                    id:subbox
                    implicitHeight: subtitle.implicitHeight
                    implicitWidth: subtitle.implicitWidth + 20
                    opacity: winroot.showSubtitle ? 1 : 0.2
                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }

                    color: Hyprland.hasMaximize ? Qt.rgba(0.031,0.031,0.070,0.3) : "#080812"
                    radius: 10
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: winroot.showSubtitle = false
                        onExited: winroot.showSubtitle = true
                        onClicked: {
                            root.showLyrics = false;
                            hideTimer.restart()
                        }
                    }

                    Text {
                        id:subtitle
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.currentLine
                        font.family: "monospace"
                        color: "white"
                        wrapMode: Text.Wrap
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 20
                    }
                }
            }
        }
    }
}
