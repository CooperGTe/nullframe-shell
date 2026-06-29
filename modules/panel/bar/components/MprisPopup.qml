import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.components
import qs.services
import qs.config

PopupWindow {
    id: popout

    property real musicSelectSize: 0
    property var popupParent
    property var loaderParent
    readonly property MprisPlayer activePlayer: MprisController.activePlayer

    anchor.item: popupParent
    anchor.rect.x: popupParent.width
    anchor.rect.y: 0
    anchor.margins.top: -shape.radius * 1.5

    implicitWidth: 300

    Component.onCompleted: { 
        popout.musicSelectSize = info.implicitHeight + shape.radius * 3
        console.log(musicSelectSize)
    }
    implicitHeight: popout.musicSelectSize * 3

    color: "transparent"

    //track change popout
    // [start]
	Connections {
		target: activePlayer

		function onPostTrackChanged() {
            popout.hoverBlocker = true
            trackChanged.restart()
        }
    }
    Timer {
        id: trackChanged
        interval: 1000
        repeat: false
        running: false
        onTriggered: popout.hoverBlocker = false
    }
    // [end]

    property bool visibility: loaderParent.item.hovered || hover2.hovered || hoverBlocker
    property bool hoverBlocker: false
    Behavior on visibility {
        SequentialAnimation {
            ScriptAction { 
                script: {
                    popout.visible = true
                }
            }
            PauseAnimation { 
                duration: 400
            }
            ScriptAction { 
                script: if (!popout.visibility) {
                    popout.visible = false
                    info.replace(musicinfo)
                }
            }
        }
    }
    Behavior on implicitWidth {
        Anim{}        
    }

    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }

    ItemShadow {

    }

    PopoutShape {
        id:shape

        side: Config.bar.position

        anchors.left:parent.left

        implicitHeight: info.currentItem?.objectName === "musicselect"
        ? info.implicitHeight + shape.radius * 3
        : loaderParent.item?.rectsize + shape.radius * 3

        implicitWidth: popout.visibility ? Math.min(info.implicitWidth, 200) + 30 : 0

        HoverHandler {
            id: hover2
            onHoveredChanged: {
                blockertimer.restart()
            }
        }
        Timer {
            id: blockertimer
            running: false
            repeat: false
            interval: 400
            onTriggered: if (!hover2.hovered) popout.hoverBlocker = false
        }

        StackView {
            id:info
            anchors.fill:parent
            clip: true
            implicitWidth: info.currentItem.implicitWidth
            implicitHeight: info.currentItem.implicitHeight
            initialItem: musicinfo
            replaceEnter: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                    easing.type: Easing.OutQuart
                }
            }
            replaceExit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 0
                    easing.type: Easing.OutQuart
                }
            }
        }
        Component {
            id: musicinfo
            ColumnLayout {
                objectName: "musicinfo"
                spacing: -20
                clip: true
                RowLayout {
                    Layout.topMargin: 10
                    IconImage {
                        source: Quickshell.iconPath(DesktopEntries.heuristicLookup(activePlayer?.desktopEntry)?.icon, activePlayer?.desktopEntry)
                        implicitSize: 15
                    }
                    StyledText {
                        surface:3
                        font.pixelSize: 12
                        text: activePlayer?.identity
                        font.bold:true
                    }
                    Button {
                        text: "Select Player"
                        onClicked: {
                            info.replace(musicselect)
                            popout.hoverBlocker = true
                        }
                        contentItem: Text {
                            text: parent.text
                            opacity: enabled ? 1.0 : 0.3
                            color: Color.secondary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            font.bold:true
                        }
                        background: Rectangle {
                            radius: 10
                            opacity: enabled ? 1.0 : 0.3
                            color: parent.down ? Color.container_high : Color.on_secondary
                        }
                    }
                }
                StyledText {
                    text: activePlayer?.trackTitle
                    elide: Text.ElideRight
                    Layout.maximumWidth: 200
                }
                StyledText {
                    Layout.bottomMargin: 20
                    Layout.topMargin: -5
                    surface:3
                    font.pixelSize: 10
                    text: activePlayer?.trackArtist
                }
            }
        }
        Component {
            id: musicselect 
            ColumnLayout {
                objectName: "musicselect"
                clip: true
                spacing: -5
                RowLayout {
                    Layout.topMargin: 20
                    MaterialIcon {
                        icon: "music_video"
                        font.pixelSize: 20
                        color: Color.primary
                    }
                    StyledText {
                        text: "Player Selector"
                        surface: 3
                        font.pixelSize: 12
                        font.bold: true
                    }
                    Button {
                        text: "Back"
                        onClicked: {
                            info.replace(musicinfo)
                            popout.hoverBlocker = true
                        }
                        contentItem: Text {
                            text: parent.text
                            opacity: enabled ? 1.0 : 0.3
                            color: Color.secondary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            font.bold:true
                        }
                        background: Rectangle {
                            radius: 10
                            opacity: enabled ? 1.0 : 0.3
                            color: parent.down ? Color.container_high : Color.on_secondary
                        }
                    }
                }
                MprisSelector {
                    text: "Automatic"
                    reset: true
                    stack: info
                    stackTarget: musicinfo
                }
                Repeater {
                    model: MprisController.allPlayer
                    MprisSelector {
                        required property var modelData
                        text: modelData.identity
                        icon: Quickshell.iconPath(DesktopEntries.heuristicLookup(this.modelData?.desktopEntry)?.icon, this.modelData.desktopEntry)
                        stack: info
                        stackTarget: musicinfo
                        mData: this.modelData
                    }
                }
                //??? margin
                Item {
                    Layout.bottomMargin: 20
                }
            }
        }
    }
}
