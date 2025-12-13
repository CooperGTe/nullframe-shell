import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import qs.modules.common
import qs.services
import qs.config

Scope {
	id: root

	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}
    // Mpris
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    // Brightness //
    FileView {
        id: brightnessFile
        path: brightnessPath.text.split("\n")[0]
        watchChanges: true
        onFileChanged: {
            reload()
            root.mode = "brightness"
            root.shouldShowOsd = true;
			hideTimer.restart();
            root.shouldAnimateOsd = true
			animTimer.restart();
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
			root.shouldShowOsd = true;
			hideTimer.restart();
            root.shouldAnimateOsd = true
			animTimer.restart();
		}
	}
    Connections {
        target: root.activePlayer

        function onVolumeChanged() {
            root.mode = "mpris"
			root.shouldShowOsd = true;
			hideTimer.restart();
            root.shouldAnimateOsd = true
			animTimer.restart();
        }
    }

	property bool shouldShowOsd: false
	property bool shouldAnimateOsd: false
    property string mode: "volume"

	Timer {
		id: hideTimer
		interval: 2000
		onTriggered: root.shouldShowOsd = false
	}
    Timer {
		id: animTimer
		interval: 1000
		onTriggered: root.shouldAnimateOsd = false
	}

	// The OSD window will be created and destroyed based on shouldShowOsd.
	// PanelWindow.visible could be set instead of using a loader, but using
	// a loader will reduce the memory overhead when the window isn't open.
	LazyLoader {
		active: root.shouldShowOsd

		PanelWindow {
			// Since the panel's screen is unset, it will be picked by the compositor
			// when the window is created. Most compositors pick the current active monitor.

			anchors.left: true
			margins.left: root.shouldAnimateOsd ? 10 : -80
			exclusiveZone: 0

			implicitWidth: 40
			implicitHeight: 150
			color: "transparent"

			// An empty click mask prevents the window from blocking mouse events.
			mask: Region {}

            Behavior on margins.left {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }

			Rectangle {
				anchors.fill: parent
				radius: height / 2
				color: Color.base
                opacity:  root.shouldAnimateOsd ? 1 : -0
                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }

				ColumnLayout {
					anchors {
						fill: parent
                        topMargin: 15
                        bottomMargin: 10
					}

                    Text {
                        Layout.alignment:Qt.AlignHCenter
                        text: root.mode === "volume" ? 
                            `${Math.round(Pipewire.defaultAudioSink?.audio.volume * 100) ?? 0}%` : 
                            root.mode === "mpris" ?
                            `${Math.round(activePlayer.volume * 100) ?? 0}%` :
                            `${Math.round(brightnessFile.text()/maxBrightness.text.split("\n")[0] * 100) ?? 0}%`
                        color: Color.surface
                        font.pixelSize: 10
                        font.bold: true
                    }	

					Rectangle {
						// Stretches to fill all left-over space
						Layout.fillHeight: true
                        Layout.alignment:Qt.AlignHCenter

						implicitWidth: 10
						radius: 20
						color: "transparent"

						Rectangle {
							anchors {
								bottom: parent.bottom
                                left: parent.left
                                right: parent.right
							}
                            color: Color.surface

                            implicitHeight: root.mode === "volume" ?
                                parent.height * (Pipewire.defaultAudioSink?.audio.volume ?? 0) :
                                root.mode === "mpris" ?
                                parent.height * activePlayer.volume :
                                parent.height * brightnessFile.text()/maxBrightness.text.split("\n")[0]
							radius: parent.radius
						}
                        Rectangle {
							anchors {
								top: parent.top
                                left: parent.left
                                right: parent.right
							}
                            color: Color.container_high

                            implicitHeight: root.mode === "volume" ?
                                parent.height * (1 - (Pipewire.defaultAudioSink?.audio.volume ?? 0)) - 1 :
                                root.mode === "mpris" ?
                                parent.height * (1 - (activePlayer.volume ?? 0)) - 1 :
                                parent.height * (1 - brightnessFile.text()/maxBrightness.text.split("\n")[0]) - 1
							radius: parent.radius
                        }
					}
                    MaterialIcon {
                        Layout.alignment:Qt.AlignHCenter
                        icon: root.mode === "volume" ? "volume_up" : root.mode === "mpris" ? "music_note" : "brightness_4"
                        font.pixelSize: 25
                        color: Color.surface
                        fill: root.mode === "volume" | "mpris" ? 1 : 0
                    }
				}
			}
		}
	}
}
