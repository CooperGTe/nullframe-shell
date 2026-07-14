pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris

import qs.components
import qs.services
import qs.config

Scope {
	id: root


    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    property string mode: "volume"
    property bool visibility: false

    // visibility logic
    function showOSD() {
            root.visibility = true
            timeOut.restart()
    }

    Behavior on visibility {
        SequentialAnimation {
            ScriptAction { 
                script: {
                    loader.active = true
                }
            }
            PauseAnimation { 
                duration: 400
            }
            ScriptAction { 
                script: if (!root.visibility) {
                    loader.active = false
                }
            }
        }
    }

    Timer {
        id: timeOut
        interval: 2000
        running: false
        onTriggered: root.visibility = false
    }

	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
    }

    // Brightness //
    FileView {
        id: brightnessFile
        path: brightnessPath.text.split("\n")[0]
        watchChanges: true
        onFileChanged: {
            reload()
            root.mode = "brightness"
            root.showOSD()
        }
    }

    Process {
        command: ["bash", "-c", "echo /sys/class/backlight/*/brightness"]
        running: true
        stdout: StdioCollector {
            id: brightnessPath
        }
    }

    Process {
        command: ["bash", "-c", "cat /sys/class/backlight/*/max_brightness"]
        running: true
        stdout: StdioCollector {
            id: maxBrightness
        }
    }

	Connections {
		target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            root.mode = "volume"
            root.showOSD()
		}
    }

    Connections {
        target: root.activePlayer

        function onVolumeChanged() {
            root.mode = "mpris"
            root.showOSD()
        }
    }

	LazyLoader {
        id:loader
		active: false

		PanelWindow {
			anchors.bottom: true
            margins.bottom: 100

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay

			implicitWidth: 240
			implicitHeight: 100

			color: "transparent"

			mask: Region {}

            ItemShadow{}

			Rectangle {
                anchors.fill: parent
                anchors.margins: 20

				color: Color.base
				radius: 15
                opacity:  root.visibility ? 1 : -0

                border.width: 1
                border.color: Color.container

                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

                RowLayout {
                    anchors {
                        fill: parent
                        margins:8
                    }
                    MaterialIcon {
                        Layout.alignment:Qt.AlignHCenter
                        icon: root.mode === "volume" ? "volume_up" : root.mode === "mpris" ? "music_note" : "brightness_4"
                        font.pixelSize: 24
                        color: Color.primary
                        fill: root.mode === "volume" | "mpris" ? 1 : 0
                    }
                    ColumnLayout {
                        RowLayout {
                            StyledText {
                                text: root.mode === "volume" ? "Audio Master Volume" : root.mode === "mpris" ? "MPD-Mpris" : "Backlight"
                                surface: 3
                                Layout.fillWidth: true
                            }

                            StyledText {
                                text: root.mode === "volume" ? 
                                `${Math.round(Pipewire.defaultAudioSink?.audio.volume * 100) ?? 0}%` : 
                                root.mode === "mpris" ?
                                `${Math.round(activePlayer.volume * 100) ?? 0}%` :
                                `${Math.round(brightnessFile.text()/maxBrightness.text.split("\n")[0] * 100) ?? 0}%`
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 2
                            Layout.rightMargin: 2
                            Layout.bottomMargin: 2

                            implicitHeight: 10
                            radius: 20
                            color: "transparent"

                            Rectangle {
                                anchors {
                                    bottom: parent.bottom
                                    top: parent.top
                                    left: parent.left
                                }

                                implicitWidth: root.mode === "volume" ?
                                parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0) :
                                root.mode === "mpris" ?
                                parent.width * activePlayer.volume :
                                parent.width * brightnessFile.text()/maxBrightness.text.split("\n")[0]

                                color: Color.primary
                                radius: parent.radius
                            }

                            Rectangle {
                                anchors {
                                    top: parent.top
                                    bottom: parent.bottom
                                    right: parent.right
                                }

                                implicitWidth: root.mode === "volume" ?
                                parent.width * (1 - (Pipewire.defaultAudioSink?.audio.volume ?? 0)) - 3 :
                                root.mode === "mpris" ?
                                parent.width * (1 - (activePlayer.volume ?? 0)) - 3 :
                                parent.width * (1 - brightnessFile.text()/maxBrightness.text.split("\n")[0]) - 3 
                                color: Color.container_high
                                radius: parent.radius
                            }

                            Rectangle {
                                anchors {
                                    right: parent.right
                                    margins: 2.5
                                    verticalCenter:parent.verticalCenter
                                }

                                implicitWidth: 5
                                implicitHeight: 5

                                color: Color.primary
                                radius: parent.radius
                            }
                        }
                    }
                }
			}
		}
	}
}
