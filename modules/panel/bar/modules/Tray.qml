pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick.Effects
import qs.config
import qs.components

Loader {
    id: root
    property bool hoverBlocker: false
    Layout.alignment: Config.barOrientation ?  Qt.AlignVCenter : Qt.AlignHCenter
    sourceComponent: Config.barOrientation ? horizontal : vertical

    Component {
        id: horizontal
        RowLayout {
            spacing: 8
            Content {}
        }
    }
    Component {
        id: vertical
        ColumnLayout {
            spacing: 8
            MaterialIcon {
                icon: "settings"
                font.pixelSize: 16
                color: Color.secondary
                Layout.alignment: Qt.AlignHCenter
                fill: 1
            }
            Text {
                text: "Tray"
                Layout.alignment: Qt.AlignHCenter
                color: Color.secondary
                font.bold: true
                rotation:90
                Layout.bottomMargin: 10
            }
            HoverHandler {
                id:hover
                margin: 10
            }
            PopupWindow {
                id:trayPopout

                property bool visibility: hover.hovered || hover2.hovered || root.hoverBlocker

                Behavior on visibility {
                    SequentialAnimation {
                        ScriptAction { 
                            script: {
                                trayPopout.visible = true
                            }
                        }
                        PauseAnimation { 
                            duration: 400
                        }
                        ScriptAction { 
                            script: if (!trayPopout.visibility) trayPopout.visible = false
                        }
                    }
                }

                implicitWidth:30
                implicitHeight:contentitem.implicitHeight + 60

                anchor.item: root
                anchor.edges: Config.bar.position === 0 ? Edges.Left
                : (Config.bar.position === 1 ? Edges.Top 
                : (Config.bar.position === 2 ? Edges.Right
                : Edges.Bottom))

                anchor.gravity: contentitem.implicitHeight <= 48 ? (Config.bar.position === 2 ? Edges.Left : Edges.Right) : Edges.Bottom

                anchor.margins {
                    left: contentitem.implicitHeight <= 48 ? 30 
                    : (Config.bar.position === 0 ? 45 : 0)
                    right: contentitem.implicitHeight <= 48 ? 30 
                    : (Config.bar.position === 2 ? 45 : 0)
                    top: contentitem.implicitHeight <= 48 ? -20 : -140
                    bottom: -20
                }

                color: "transparent"

                HoverHandler {
                    id:hover2
                }

                component Anim: NumberAnimation {
                    duration: 400
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
                }

                PopoutShape {
                    id:shape

                    side: Config.bar.position
                    states: [
                        State {
                            name: "left"
                            when: Config.bar.position === 0
                            AnchorChanges {
                                target: shape
                                anchors.left: parent.left
                            }
                        },
                        State {
                            name: "top"
                            when: Config.bar.position === 1
                            AnchorChanges {
                                target: shape
                                anchors.top: parent.top
                            }
                        },
                        State {
                            name: "right"

                            when: Config.bar.position === 2
                            AnchorChanges {
                                target: shape
                                anchors.right: parent.right
                            }
                        },
                        State {
                            name: "bottom"
                            when: Config.bar.position === 3
                            AnchorChanges {
                                target: shape
                                anchors.bottom: parent.bottom
                            }
                        }
                    ]

                    implicitHeight: trayPopout.implicitHeight
                    implicitWidth: trayPopout.visibility ? 30 : 0

                    ColumnLayout {
                        id:contentitem
                        states: [
                            State {
                                name: "left"
                                when: Config.bar.position === 0
                                AnchorChanges {
                                    target: contentitem
                                    anchors.right: parent.right
                                    anchors.verticalCenter:parent.verticalCenter
                                }
                            },
                            State {
                                name: "top"
                                when: Config.bar.position === 1
                                AnchorChanges {
                                    target: contentitem
                                    anchors.top: parent.top
                                }
                            },
                            State {
                                name: "right"

                                when: Config.bar.position === 2
                                AnchorChanges {
                                    target: contentitem
                                    anchors.left: parent.left
                                    anchors.verticalCenter:parent.verticalCenter
                                }
                            },
                            State {
                                name: "bottom"
                                when: Config.bar.position === 3
                                AnchorChanges {
                                    target: contentitem
                                    anchors.bottom: parent.bottom
                                }
                            }
                        ]
                        anchors {
                            rightMargin: Config.bar.position === 0 ? 15/2 : 0
                            bottomMargin: Config.bar.position === 1 ? 15/2 : 0
                            leftMargin: Config.bar.position === 2 ? 15/2 : 0
                            topMargin: Config.bar.position === 3 ? 15/2 : 0
                        }
                        Content {}
                    }
                }
            }
        }
    }

    component Content : Repeater {
        model: SystemTray.items

        IconImage {
            id: icon
            required property SystemTrayItem modelData
            source: modelData.icon
            implicitSize: 16
            layer.enabled: true
            layer.effect: MultiEffect {
                contrast:0.2
                brightness:0
                saturation:-0.5
            }

            ToolTip {
                id: toolTip
                popupType: Popup.Native
                y: icon.implicitSize * 2
                delay: 500

                contentItem: Text {
                    text: toolTip.text
                    color: Color.primary
                }

                background: Rectangle {
                    color: Color.base
                    radius: 6
                }
            }
            PopupWindow {
                id:popout
                property bool visibility: false
                onVisibleChanged: {
                    if (visible) popout.visibility = true
                }
                Behavior on visibility {
                    SequentialAnimation {
                        ScriptAction { 
                            script: popout.visible = true
                        }
                        PauseAnimation { 
                            duration: 400
                        }
                        ScriptAction { 
                            script: if (!popout.visibility) popout.visible = false
                        }
                    }
                }
                anchor.item: parent
                anchor.edges: Config.bar.position === 0 ? Edges.Left
                : (Config.bar.position === 1 ? Edges.Top 
                : (Config.bar.position === 2 ? Edges.Right
                : Edges.Bottom))

                anchor.gravity: Config.bar.position === 0 ? Edges.Right
                : (Config.bar.position === 1 ? Edges.Bottom 
                : (Config.bar.position === 2 ? Edges.Left
                : Edges.Top))    

                anchor.margins{
                    left: (Config.bar.position === 0) ? Config.barTotalWidth : 0
                    top: (Config.bar.position === 1) ? Config.barTotalWidth : 0
                    right: (Config.bar.position === 2) ? Config.barTotalWidth : 0
                    bottom: (Config.bar.position === 3) ? Config.barTotalWidth : 0
                }

                color: "transparent"
                implicitWidth: childColumn.implicitWidth + 10
                implicitHeight: childColumn.height + 10

                HyprlandFocusGrab {
                    id: grab
                    windows: [ popout ]
                    onActiveChanged: {
                        if (!grab.active) {
                            popout.visibility = false
                            root.hoverBlocker = false
                        }
                    }
                }

                Rectangle {
                    anchors.fill:parent
                    color: Color.base
                    radius:10
                    border.width: 1
                    border.color: Color.container
                    scale: popout.visibility ? 1 : 0.9
                    opacity: popout.visibility ? 1 : 0

                    Behavior on scale {
                        Anim {}
                    }
                    Behavior on opacity {
                        Anim {}
                    }

                    ColumnLayout {
                        anchors.margins: 5
                        anchors.centerIn:parent
                        id: childColumn
                        spacing: 5

                        Repeater {
                            model: menuOpener.children
                            delegate: TrayMenuItem {
                                parentColumn: childColumn
                                Layout.preferredWidth: childColumn.width > 0 ? childColumn.width : implicitWidth
                            }
                        }
                    }
                }           
            }
            QsMenuOpener {
                id: menuOpener
                menu: icon.modelData.menu
            }
            /*
            QsMenuAnchor {
                id: menuAnchor
                anchor.item: icon
                anchor.edges: Edges.Left
                anchor.gravity: Edges.Right

                anchor.margins {
                    left:35
                }

                menu: icon.modelData.menu
            }
            */
            MouseArea {
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                anchors.fill: parent

                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton)
                    icon.modelData.activate();
                    else if (mouse.button === Qt.RightButton)
                    popout.visible = !popout.visible
                    grab.active = true
                    root.hoverBlocker = true
                    //menuAnchor.open()
                }

                onEntered: {
                    if (icon.modelData.tooltipTitle === "")
                    return;

                    toolTip.show(icon.modelData.tooltipTitle);
                }

                onExited: toolTip.hide()
            }
        }
    }
    component TrayMenuItem: Item {
        id: itemRoot
        required property QsMenuEntry modelData
        required property ColumnLayout parentColumn

        Layout.fillWidth: true
        implicitWidth: rowLayout.implicitWidth + 10
        implicitHeight: !itemRoot.modelData.isSeparator ? rowLayout.implicitHeight + 10 : 1

        MouseArea {
            id: hover
            hoverEnabled: itemRoot.modelData.enabled
            anchors.fill: parent
            onClicked: {
                if (!itemRoot.modelData.hasChildren)
                itemRoot.modelData.triggered()
                //what?
                root.hoverBlocker = false
            }
        }

        Rectangle {
            id: itemBg
            anchors.fill: parent
            opacity: itemRoot.modelData.isSeparator ? 0.5 : 1
            radius: 5
            color: itemRoot.modelData.isSeparator
            ? Color.container_highest
            : hover.containsMouse ? Color.container : "transparent"
        }

        RowLayout {
            id: rowLayout
            visible: !itemRoot.modelData.isSeparator
            opacity: itemRoot.modelData.isSeparator ? 0.5 : 1
            spacing: 5
            anchors {
                left: itemBg.left
                leftMargin: 5
                top: itemBg.top
                topMargin: 5
            }
            //wip
            Rectangle {
                width: 26
                height: 26
                visible: itemRoot.modelData.buttonType === "RadioButton" ? true : false
                border.color: "#21be2b"
                radius: 3
                Rectangle {
                    width: 14
                    height: 14
                    anchors.centerIn: parent
                    color: "#21be2b"
                    radius: 2
                }
            }

            IconImage {
                visible: itemRoot.modelData.icon !== ""
                source: itemRoot.modelData.icon
                width: 15
                height: 15
                //Component.onCompleted: console.log(itemRoot.modelData.buttonType)
            }
            // known bug, the text doesnt update?
            Text {
                text: itemRoot.modelData.text
                color: Color.secondary
            }

            MaterialIcon {
                visible: itemRoot.modelData.hasChildren
                icon: "chevron_right"
                font.pixelSize: 16
            }
        }
    }
}
