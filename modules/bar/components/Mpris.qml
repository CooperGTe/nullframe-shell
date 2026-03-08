import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell.Widgets
import Quickshell.Services.Mpris
import Quickshell
import qs.services
import qs.components
import qs.config

Item {
    id:root
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: !Config.barOrientation ? player.implicitHeight : 40
    implicitWidth: Config.barOrientation ? player.implicitWidth : 40

    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property real position: MprisController.visualPosition

    Loader {
        id: player
        anchors.fill: parent
        sourceComponent: Config.barOrientation ? horizontal : vertical
    }
    
    PopupWindow {
        id: popout

        anchor.item: root
        anchor.rect.x: root.width
        anchor.rect.y: 0
        anchor.margins.top: -shape.radius * 1.5

        implicitWidth: 300

        property real musicSelectSize: 0
        Component.onCompleted: { 
            popout.musicSelectSize = info.implicitHeight + shape.radius * 3
            console.log(musicSelectSize)
        }
        implicitHeight: popout.musicSelectSize * 3

        color: "transparent"

        property bool visibility: player.item.hovered || hover2.hovered || hoverBlocker
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

        Shape {
            id:shape
            anchors.left:parent.left
            height: info.currentItem.objectName === "musicselect" ? 
            info.implicitHeight + shape.radius * 3 :
            player.item.rectsize + shape.radius * 3
            property real radius:15
            property bool flatten: shape.width < shape.radius * 2
            property real radiusRounding: shape.flatten ? shape.width / 2 : shape.radius
            width: popout.visibility ? Math.min(info.implicitWidth, 200) + 30 : 0

            Behavior on width {
                Anim{}        
            }
            Behavior on height {
                Anim{}        
            }

            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeWidth: 0
                fillColor:Color.base

                PathArc { 
                    relativeY:shape.radius
                    relativeX:shape.radiusRounding
                    radiusY: shape.radius
                    radiusX: Math.min(shape.radius, shape.width)
                    direction: PathArc.Counterclockwise
                }
                PathLine { 
                    relativeX: shape.width - shape.radiusRounding * 2
                    relativeY: 0
                }
                PathArc { 
                    relativeY:shape.radius
                    relativeX:shape.radiusRounding
                    radiusY: shape.radius
                    radiusX: Math.min(shape.radius, shape.width)
                }
                PathLine { 
                    relativeX: 0
                    relativeY: shape.height - (shape.radius * 4)
                }
                PathArc { 
                    relativeY:shape.radius
                    relativeX:-shape.radiusRounding
                    radiusY: shape.radius
                    radiusX: Math.min(shape.radius, shape.width)
                }
                PathLine { 
                    relativeX: -shape.width - -shape.radiusRounding * 2
                    relativeY: 0
                }
                PathArc { 
                    relativeY:shape.radius
                    relativeX:-shape.radiusRounding
                    radiusY: shape.radius
                    radiusX:Math.min(shape.radius, shape.width)
                    direction: PathArc.Counterclockwise
                }
            }

            HoverHandler {
                id: hover2
                onHoveredChanged: {
                    blockertimer.restart()
                    //console.log("[DEBUG] HOVER2: ", hover2.hovered, popout.hoverBlocker)
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
                            font.pixelSize: 10
                            text: activePlayer?.identity
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
                            color: Color.surface
                        }
                        StyledText {
                            text: "Player Selector"
                            surface: 3
                            font.pixelSize: 10
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
                            }
                            background: Rectangle {
                                radius: 10
                                opacity: enabled ? 1.0 : 0.3
                                color: parent.down ? Color.container_high : Color.on_secondary
                            }
                        }
                    }
                    Selector {
                        text: "Automatic"
                        reset: true
                    }
                    Repeater {
                        model: MprisController.allPlayer
                        Selector {
                            text: modelData.identity
                            icon: Quickshell.iconPath(DesktopEntries.heuristicLookup(modelData?.desktopEntry)?.icon, modelData.desktopEntry)
                        }
                    }
                    component Selector: Rectangle {
                        id: root
                        property string icon
                        property string text
                        property bool reset: false
                        color: Color.container
                        radius: 5
                        implicitHeight: 20
                        Layout.fillWidth: true
                        Layout.rightMargin: 10
                        MouseArea {
                            anchors.fill:parent
                            onClicked: {
                                info.replace(musicinfo)
                                if (!reset) MprisController.setActivePlayer(modelData)
                                if (reset) MprisController.resetAutoPlayer()
                            }
                        }
                        RowLayout {
                            anchors.fill:parent
                            MaterialIcon {
                                icon: "autorenew"
                                font.pixelSize:16
                                color: Color.secondary
                                visible: !root.icon
                                Layout.leftMargin: 10
                            }
                            IconImage {
                                Layout.leftMargin: 10
                                source: root.icon
                                implicitSize: 15
                                visible: root.icon
                            }
                            StyledText {
                                Layout.rightMargin: 10
                                Layout.fillWidth: true
                                horizontalAlignment: Text.Left
                                text: root.text
                                surface: 2
                            }
                            MaterialIcon {
                                icon: "check"
                                font.pixelSize:20
                                color: Color.secondary
                                visible: if (root.reset) !MprisController.lock
                                    else if (!root.reset && MprisController.lock) MprisController.trackedPlayer === modelData
                                    else false
                                Layout.leftMargin: 10
                            }
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

    component MediaButton: Button {
        id: root

        property real trigger
        property var parentRoot
        property var media
        property string iconName

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 28
        Layout.preferredHeight: 28
        background: Rectangle { color: "transparent" }
        onClicked: root.media.togglePlaying() //triggerable when the mouse area is not loaded; when the trigger = 3

        Loader {
            anchors.fill: parent
            sourceComponent: root.trigger === 0 ? mediaBtn1 : 
            (root.trigger === 1 ? mediaBtn1 :
            (root.trigger === 2 ? mediaBtn2 :
            mediaBtn3))
        }
        Component {
            id: mediaBtn1
            Item {
                anchors.fill: parent
                MaterialIcon {
                    anchors.centerIn: parent
                    icon: root.iconName
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
                    onClicked: root.trigger === 0 ? root.media.previous() : root.media.next()
                }
            }
        }

        Component {
            id: mediaBtn2
            Item {
                anchors.fill: parent
                ClippedFilledCircularProgress {
                    size: 28
                    value: parentRoot.position / root.media.length
                    colPrimary: Color.primary
                    colSecondary: Color.container_highest
                    lineWidth: 3
                    Item {
                        anchors.fill: parent
                        MaterialIcon {
                            anchors.centerIn: parent
                            fill: 1
                            icon: activePlayer && activePlayer.isPlaying ? "pause" : "play_arrow"
                            font.pixelSize: activePlayer && activePlayer.isPlaying ? 15 : 18 //size patch
                            color: Color.surface
                        }
                    }
                }
                WheelHandler {
                    target: null
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0) {
                            root.media.seek(-5)
                            MprisController.visualPosition -= 5
                        }
                        else if (event.angleDelta.y > 0) {
                            root.media.seek(5)
                            MprisController.visualPosition += 5
                        }
                    }
                }
            }
        }
        
        Component {
            id: mediaBtn3
            Item {
                anchors.fill: parent
                MaterialIcon {
                    anchors.centerIn: parent
                    icon: root.iconName
                    font.pixelSize: 20
                    color: Color.surface
                    fill: parent.hovered ? 1 : 0
                }
                WheelHandler {
                    target: null
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0) {
                            activePlayer.volume -= 0.02
                        }
                        else if (event.angleDelta.y > 0) {
                            activePlayer.volume += 0.02
                        }
                    }
                }
            }
        }
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
                    color: Color.container
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: 5
                    Layout.rightMargin: 5 
                    radius: 20
                    implicitHeight: musicctl.implicitHeight

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
            spacing: 0

            Rectangle {
                color: Color.container
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                radius: 20
                implicitHeight: 30
                implicitWidth: musicctl.implicitWidth

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
