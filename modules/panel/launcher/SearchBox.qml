import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs.components
import qs.config

import "root:/utils/scripts/math.js" as UnitMath

Rectangle {
    id:root

    required property var parentRoot
    required property var launcherContentPointer

    property var searchPointer: search
    
    color: Color.base
    radius: 15
    Layout.fillWidth: true
    Layout.bottomMargin: 5 + Config.bar.borderWidth
    implicitHeight: 85

    Column {
        anchors.fill:parent
        anchors.margins: 5
        spacing: 5

        Rectangle {
            height: 20
            width: parent.width

            color: Color.surface_container
            radius: 10

            Rectangle {
                x: switch(root.parentRoot.modeIndex) {
                    case 1: return web.x
                    case 2: return cb.x
                    case 3: return emoji.x
                    case 4: return cmd.x
                    default: return app.x
                }
                width: switch(root.parentRoot.modeIndex) {
                    case 1: return web.width + 10
                    case 2: return cb.width + 10
                    case 3: return emoji.width + 10
                    case 4: return cmd.width + 10
                    default: return app.width + 10
                }

                Behavior on width { Anim{} }
                Behavior on x { Anim{} }

                height:20

                anchors.verticalCenter:parent.verticalCenter

                color: Color.secondary
                radius: 10
            }

            RowLayout {
                spacing: 10
                width: parent.width-10
                anchors.centerIn:parent
                anchors.margins: 5
                anchors.verticalCenter:parent.verticalCenter

                StyledText {
                    id:app
                    text: "Apps"
                    color: root.parentRoot.modeIndex === 0 ? Color.on_secondary : Color.on_surface
                    Behavior on color { CAnim{} }
                }
                StyledText {
                    id:web
                    text: "Web"
                    color: root.parentRoot.modeIndex === 1 ? Color.on_secondary : Color.on_surface
                    Behavior on color { CAnim{} }
                }
                StyledText {
                    id:cb
                    text: "Clipboard"
                    color: root.parentRoot.modeIndex === 2 ? Color.on_secondary : Color.on_surface
                    Behavior on color { CAnim{} }
                }
                StyledText {
                    id:emoji
                    text: "Emoji"
                    color: root.parentRoot.modeIndex === 3 ? Color.on_secondary : Color.on_surface
                    Behavior on color { CAnim{} }
                }
                StyledText {
                    id:cmd
                    text: "Command"
                    color: root.parentRoot.modeIndex === 4 ? Color.on_secondary : Color.on_surface
                    Behavior on color { CAnim{} }
                }

                Item { 
                    Layout.fillWidth: true 
                }

                Rectangle {
                    implicitWidth:40
                    implicitHeight:20
                    radius:18
                    color: Color.surface_container_high
                    Row {
                        anchors.centerIn:parent
                        Button {
                            focusPolicy: Qt.NoFocus
                            implicitHeight:20
                            background: Rectangle {
                                color: !root.parentRoot.listview ? Color.surface_container_high : Color.secondary
                                radius: 16
                            }
                            contentItem: Row {
                                MaterialIcon {
                                    icon: "lists"
                                    color: !root.parentRoot.listview ? Color.secondary : Color.surface_container
                                    font.pixelSize: 16
                                    anchors.verticalCenter:parent.verticalCenter
                                }
                            }
                            onClicked: root.parentRoot.listview = true
                        }
                        Button {
                            focusPolicy: Qt.NoFocus
                            implicitHeight:20
                            background: Rectangle {
                                color: root.parentRoot.listview ? Color.surface_container_high : Color.secondary
                                radius: 16
                            }
                            contentItem: Row {
                                MaterialIcon {
                                    icon: "grid_view"
                                    color: root.parentRoot.listview ? Color.secondary : Color.surface_container
                                    font.pixelSize: 16
                                    anchors.verticalCenter:parent.verticalCenter
                                }
                            }
                            onClicked: root.parentRoot.listview = false
                        }
                    }
                }
            }
        }
        Item {
            height: 30
            width: parent.width

            TextField {
                id: search

                height: 30
                width: parent.width - (math.visible ? math.implicitWidth + 5 : 0)

                background: Rectangle {
                    color: Color.surface_container
                    radius: 10
                }

                placeholderText: " Type to search | 󰃬 Type Math Expression"
                color: Color.on_surface

                onTextChanged: {
                    root.parentRoot.selectedIndex = 0
                    //root.stackPointer.currentItem.positionViewAtIndex(0, ListView.Beginning)
                }
            }
            Rectangle {
                id: math

                implicitWidth: mathResult.width + 20
                implicitHeight: 30

                anchors.right:parent.right

                color: Color.tertiary
                radius: 10

                visible: mathResult.text !== "󰃬 "

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom

                Text {
                    id: mathResult

                    anchors.centerIn:parent

                    text: "󰃬 " + math.evaluateExpression(search.text)
                    font.pixelSize: 16
                    font.bold: true
                    color: Color.on_tertiary
                }

                function evaluateExpression(expr) {
                    if (expr.length === 0)
                    return ""
                    try {
                        return UnitMath.evaluate(expr)
                    } catch (e) {
                        return ""
                        //return "Error: " + e.message
                    }
                }

            }

        }
        Item {
            height: 20
            width:parent.width - 10

            anchors.margins: 5
            anchors.left:parent.left
            StyledText {
                text: "󰍠/󰍝 󰍞/󰍟: navigation"
                surface:3
            }
            StyledText {
                text: "󰌑  : proceed  󰌒  : switch mode"
                surface:3
                anchors.right:parent.right
            }
        }
    }
    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }
    component AnimE: NumberAnimation {
        duration: 600
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }
    component CAnim: ColorAnimation { 
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
    }
}

