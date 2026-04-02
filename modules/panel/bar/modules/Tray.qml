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
                anchor.item: parent
                anchor.edges: Edges.Left
                anchor.gravity: contentitem.implicitHeight <= 48 ? Edges.Right : Edges.Bottom
                anchor.margins{
                    left: contentitem.implicitHeight <= 40 ? 30 : 45
                    right: 0
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
                    anchors.left:parent.left
                    height: trayPopout.implicitHeight
                    width: trayPopout.visibility ? 30 : 0

                    ColumnLayout {
                        id:contentitem
                        anchors {
                            right:parent.right
                            verticalCenter:parent.verticalCenter
                            rightMargin:15/2
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
                    color: Color.surface
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
                anchor.edges: Edges.Left
                anchor.gravity: Edges.Right
                anchor.margins{
                    left: 30
                    right: 0
                    top:-20
                    bottom: -20

                }
                color: "transparent"
                width: childColumn.implicitWidth + 10
                height: childColumn.height + 10

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
                Component.onCompleted: console.log(itemRoot.modelData.buttonType)
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
