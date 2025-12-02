pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    Scope {
        id:scope
        required property var modelData
        property bool visible: false
        property string method: "fcitx5 (en_US)"
        property string mode: "no"
        Process {
            id: capsCheck
            command: ["bash", "-c", "hyprctl devices | grep -B 6 'main: yes' | grep 'capsLock' | head -1 | awk '{ print $2}'"]
            running: false

            stdout: StdioCollector {
                onStreamFinished: {
                    scope.mode = this.text.trim()
                }
            }
        }
        Process {
            id: imeCheck
            command: ["bash", "-c", "fcitx5-remote -n"]
            running: false

            stdout: StdioCollector {
                onStreamFinished: {
                    scope.method = this.text.trim() === "keyboard-us" ? "fcitx5 (en_US)" : "fcitx5 (日本語)"
                }
            }
        }
        GlobalShortcut {
            name: "capslock"
            onPressed: {
                capsCheck.running = false
            }
            onReleased: {
                capsCheck.running = true
                scope.visible = true
                hideTimer.restart()
            }
        }
        GlobalShortcut {
            name: "fcitx5"
            onPressed: {
                imeCheck.running = false
            }
            onReleased: {
                imeCheck.running = true
                scope.visible = true
                hideTimer.restart()
            }
        }
        Timer {
            id: hideTimer
            interval: 1000
            onTriggered: if (scope.mode === "no") scope.visible = false
        }

        LazyLoader {
            active:scope.visible
            PanelWindow {
                id:root
                screen: scope.modelData
                WlrLayershell.layer: WlrLayer.Overlay
                exclusiveZone:0
                
                implicitWidth: 150
                implicitHeight:80
                color: "transparent"
                margins.bottom:50
                mask: Region {}
                anchors {
                    bottom: true
                }

                Rectangle {
                    anchors.fill:parent
                    color:"#080812"
                    border.width: scope.mode === "yes" ? 2 : 0
                    border.color: "#ffadad"
                    radius:20
                    ColumnLayout {
                        anchors.fill:parent
                        anchors.margins:10
                        spacing:0
                        Text {
                            Layout.alignment:Qt.AlignTop
                            text: "Keyboards Mode"
                            color: "#dfdfff"
                        }
                        Text {
                            text: scope.method
                            Layout.alignment:Qt.AlignTop
                            color: "#afafbf"
                        }
                        Text {
                            text: if (scope.method === "fcitx5 (en_US)")
                                return scope.mode === "yes" ? "Capslock: ON" : "Capslock: OFF"
                            else
                                return scope.mode === "yes" ? "カタカナ" : "ひらがな"
                            color: "#dfdfff"
                            font.family: "monospace"
                            font.pixelSize:16
                            horizontalAlignment:font.horizontalCenter
                            font.bold:true
                            Layout.fillHeight:true
                            Layout.alignment:Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
