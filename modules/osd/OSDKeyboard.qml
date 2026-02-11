pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.config
import qs.modules.common

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
        // ==============================================
        // NON HARDCODED METHOD LATER CUZ I DIDNT NEED IT
        // ==============================================
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
            onTriggered: {
                if (scope.mode === "no" && scope.method === "fcitx5 (en_US)") scope.visible = false
                console.log(scope.mode, scope.method)
            }
        }

        LazyLoader {
            active:scope.visible
            PanelWindow {
                id:root
                screen: scope.modelData
                WlrLayershell.layer: WlrLayer.Overlay
                exclusiveZone:0
                
                implicitWidth: itemcontent.implicitWidth + 30
                implicitHeight:30
                color: "transparent"
                margins.top:10
                mask: Region {}
                anchors {
                    top: true
                }

                Rectangle {
                    anchors.fill:parent
                    color:Color.base
                    radius:20
                    RowLayout {
                        id:itemcontent
                        anchors.fill:parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing:0
                        MaterialIcon {
                            icon: scope.mode === "yes" ? "lock" : "lock_open"
                            color: Color.surface
                            font.pointSize: 16
                        }
                        Text {
                            text: if (scope.method === "fcitx5 (en_US)")
                                return scope.mode === "yes" ? "Capslock: ON" : "Capslock: OFF"
                            else
                                return scope.mode === "yes" ? "カタカナ" : "ひらがな"
                            color: Color.surface
                            font.family: "monospace"
                            font.bold:true
                            Layout.alignment:Qt.AlignLeft
                            horizontalAlignment: Text.AlignLeft
                        }
                        Text {
                            text: scope.method !== "fcitx5 (en_US)" ? scope.method : ""
                            color: Color.surface_mid
                            Layout.alignment:Qt.AlignRight
                            horizontalAlignment: Text.AlignLeft
                        }
                    }
                }
            }
        }
    }
}
