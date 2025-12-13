pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts
import Quickshell.Wayland
import qs.services
import qs.config
import Quickshell.Services.Mpris

Scope {
    id: root
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property real position: MprisController.visualPosition
    Variants {
        model: Quickshell.screens
        LazyLoader {
            active: Hyprland.hasTiling ? false : true
            required property var modelData
            PanelWindow {
                id:wgRoot
                // Layer props
                screen: modelData
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.layer: WlrLayer.Bottom
                color: "transparent"

                anchors {
                    bottom: true
                    right: true
                }
                implicitWidth:content.implicitWidth + 30
                implicitHeight:content.implicitHeight + 30
                ColumnLayout {
                    id:content
                    spacing:0
                    Item {
                        implicitWidth: clock.implicitWidth
                        implicitHeight: clock.implicitHeight
                        Layout.alignment: Qt.AlignRight
                        MouseArea {
                            anchors.fill:parent
                            onClicked: Config.desktopWidget.invertClockColor = !Config.desktopWidget.invertClockColor
                        }
                        ColumnLayout {
                            id:clock
                            anchors.fill:parent
                            Text {
                                text: Time.format("hh:mm")
                                Layout.alignment: Qt.AlignRight
                                color: Config.desktopWidget.invertClockColor ? Color.base : Color.surface
                                font.pixelSize: 50
                                font.bold:true
                                font.family: "monospace"
                            }
                            Text {
                                text: Time.format("yyyy年MM月dd日")
                                Layout.alignment: Qt.AlignRight
                                Layout.topMargin: -10
                                color: Config.desktopWidget.invertClockColor ? Color.base : Color.surface
                                font.pixelSize: 15
                                font.bold: false
                            }
                        }
                    }
                    Rectangle {
                        visible: Config.desktopWidget.media
                        Layout.alignment: Qt.AlignRight
                        Layout.topMargin: 10
                        color: Color.base
                        implicitHeight: 70
                        implicitWidth: 230
                        radius:50
                        RowLayout {
                            anchors.fill: parent
                            ClippingRectangle {
                                implicitWidth:60
                                implicitHeight:60
                                Layout.leftMargin:5
                                radius:60
                                clip: true
                                color: Color.container
                                Image {
                                    anchors.fill: parent
                                    source: root.activePlayer?.trackArtUrl ?? ""
                                    fillMode: Image.PreserveAspectCrop
                                    cache: true
                                }
                            }
                            ColumnLayout{
                                Layout.rightMargin:25
                                Text{
                                    Layout.alignment:Qt.AlignBottom
                                    text:root.activePlayer.trackTitle ?? ""
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 140
                                    font.pixelSize: 12
                                    color:Color.surface
                                    font.bold:true
                                }
                                Text{
                                    Layout.alignment:Qt.AlignTop
                                    text:root.activePlayer.trackArtist ?? ""
                                    Layout.maximumWidth: 140
                                    Layout.topMargin: -5
                                    font.pixelSize: 8
                                    color:Color.surface_mid
                                }
                                Rectangle {
                                    // Stretches to fill all left-over space
                                    Layout.fillWidth: true
                                    Layout.alignment:Qt.AlignVCenter

                                    implicitHeight: 10
                                    radius: 20
                                    color: "transparent"

                                    Rectangle {
                                        anchors {
                                            bottom: parent.bottom
                                            top: parent.top
                                            left: parent.left
                                        }
                                        color: Color.surface

                                        implicitWidth: parent.width * (root.position / activePlayer.length)
                                        radius: parent.radius
                                    }
                                    Rectangle {
                                        anchors {
                                            top: parent.top
                                            bottom: parent.bottom
                                            right: parent.right
                                        }
                                        color: Color.container_high

                                        implicitWidth: parent.width * (1 - (root.position / activePlayer.length)) - 1
                                        radius: parent.radius
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
