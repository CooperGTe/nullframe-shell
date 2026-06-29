pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell
import qs.services
import qs.config

import "../components/"

Item {
    id:root

    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property real position: MprisController.visualPosition

    property bool roundStart: false
    property bool roundEnd: true

    Layout.alignment: Qt.AlignHCenter

    implicitHeight: !Config.barOrientation ? player.implicitHeight : 40
    implicitWidth: Config.barOrientation ? player.implicitWidth : 40

    Loader {
        id: player
        anchors.fill: parent
        sourceComponent: Config.barOrientation ? horizontal : vertical
    }
                                
    MprisPopup {
        popupParent: root
        loaderParent: player
    }

    Component {
        id: vertical

        ColumnLayout {
            property bool hovered: hover.hovered
            property real rectsize: box.implicitHeight

            spacing: 0

            ColumnLayout {
                Layout.fillWidth:true
                Layout.fillHeight:true

                HoverHandler {
                    id: hover
                }

                Rectangle {
                    id:box

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5 

                    color: Color.container
                    radius: 20

                    implicitHeight: musicctl.implicitHeight

                    topLeftRadius: root.roundStart ? 30 : 8
                    topRightRadius: root.roundStart ? 30 : 8
                    bottomLeftRadius: root.roundEnd ? 30 : 8
                    bottomRightRadius: root.roundEnd ? 30 : 8

                    ColumnLayout {
                        spacing: 0
                        id: musicctl
                        anchors.fill: parent

                        MediaButton {
                            iconName: "skip_previous"
                            trigger: 0
                            media: activePlayer
                        }

                        MediaButton {
                            trigger: 2
                            parentRoot: root
                            media: activePlayer
                        }

                        MediaButton {
                            iconName: "skip_next"
                            trigger: 1
                            media: activePlayer
                        }
                    }
                }
            }
            MediaButton {
                iconName: "music_note"
                trigger: 3
                media: activePlayer
            }
        }
    }
    Component {
        id: horizontal
        RowLayout { 
            property bool hovered: hover.hovered
            property real rectsize: box.implicitHeight

            spacing: 0

            RowLayout {
                Layout.fillWidth:true
                Layout.fillHeight:true
                HoverHandler {
                    id: hover
                }
                Rectangle {
                    id:box
                    color: Color.container
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    radius: 20
                    implicitHeight: 30
                    implicitWidth: musicctl.implicitWidth

                    topLeftRadius: root.roundStart ? 30 : 8
                    topRightRadius: root.roundEnd ? 30 : 8
                    bottomLeftRadius: root.roundStart ? 30 : 8
                    bottomRightRadius: root.roundEnd ? 30 : 8

                    RowLayout {
                        spacing: 0
                        id: musicctl
                        anchors.fill: parent
                        MediaButton {
                            iconName: "skip_previous"
                            trigger: 0
                            media: activePlayer
                        }

                        MediaButton {
                            trigger: 2
                            parentRoot: root
                            media: activePlayer
                        }

                        MediaButton {
                            iconName: "skip_next"
                            trigger: 1
                            media: activePlayer
                        }
                    }
                }
                MediaButton {
                    iconName: "music_note"
                    trigger: 3
                    media: activePlayer
                }       
            }
        }
    }
}
