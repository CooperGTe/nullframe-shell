pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.components
import qs.config
import qs.modules

import "../../../utils/scripts/fuzzysort.js" as Fuzzysort

Rectangle {
    id:root

    required property var parentRoot
    required property int index
    required property string searchText
    required property bool visibility

    property int listcount: stack.currentItem.count

    Connections {
        target: root.parentRoot

        function onListviewChanged() {
            root.parentRoot.listview ? stack.replace(list) : stack.replace(grid)
            console.log('test', root.parentRoot.listview)
        }
    }

    function exec() {
        stack.currentItem.model.values[root.index].execute()
    }

    clip:true

    Layout.preferredHeight: stack.currentItem.contentItem.height < 300
    ? stack.currentItem.contentItem.height + (stack.currentItem.contentItem.height < 10 ? 0 : 10)
    : 300

    // --- EnterExit Animation ---
    Layout.bottomMargin: root.visibility ? 0 : -20

    Behavior on Layout.bottomMargin { Anim{} }
    Behavior on Layout.preferredHeight { Anim{} }

    implicitWidth: 400

    color: Color.base
    radius: 15

    Item {
        anchors.fill:parent
        anchors.margins: 5

        ClippingRectangle {
            clip: true
            radius: 10
            color: "transparent"

            anchors.fill:parent

            visible: stack.currentItem.count > 0

            StackView {
                id: stack
                implicitWidth:400
                implicitHeight:300
                clip:true
                initialItem: list
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
                        duration: 400
                        easing.type: Easing.OutQuart
                    }
                }        
            }
        }
    }
    Component {
        id: list
        ListView {
            objectName: "list"

            spacing: 5

            currentIndex: root.index

            highlightFollowsCurrentItem: true   // <- viewport tracks currentItem
            highlightMoveDuration: 120          // smooth scroll animation (optional)

            function reloadModel() {
                opacity = 0

                Qt.callLater(() => {
                    model = newModel
                    opacity = 1
                })
            }

            model: ScriptModel {
                values: root.searchText.length === 0
                ? [...DesktopEntries.applications.values]
                : Fuzzysort.go(root.searchText,
                [...DesktopEntries.applications.values],
                { key: "name" })
                .map(r => r.obj)
            }
            delegate: Rectangle {
                id:itemList

                required property DesktopEntry modelData
                required property int index

                implicitHeight: 40
                implicitWidth: ListView.view.width - 10

                radius: 10

                color: root.index === index 
                ? Color.on_secondary
                : Color.surface_container

                Behavior on color { CAnim{} }

                MouseArea {
                    anchors.fill:parent
                    onClicked: {
                        if (root.index === itemList.index) {
                            root.exec()
                            Global.get(root.parentRoot.screen).launcherVisibility = false
                        } else {
                            root.parentRoot.selectedIndex = itemList.index
                        }
                    }
                }

                RowLayout {
                    anchors.fill:parent
                    anchors.margins: 5
                    Rectangle {
                        implicitHeight: 25
                        implicitWidth: root.index === itemList.index ? 3 : 0
                        color: root.index === itemList.index ? Color.primary : "transparent"
                        radius: 10
                    }
                    IconImage {
                        asynchronous:true
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        source: Quickshell.iconPath(itemList.modelData.icon || "", true)
                    }
                    ColumnLayout {
                        spacing:0
                        StyledText {
                            Layout.fillWidth: true
                            text: itemList.modelData.name
                            horizontalAlignment: Text.AlignLeft
                            surface: root.index === itemList.index ? 2 : 1
                            size: 10
                        }
                        StyledText {
                            Layout.fillWidth: true
                            visible: itemList.modelData.comment === ""?false:true
                            text: itemList.modelData.comment
                            horizontalAlignment: Text.AlignLeft
                            surface: 3
                            size: 8
                        }
                    }
                }
            }
        }
    }
    Component {
        id: grid
        GridView {
            id: gridview
            objectName: "grid"

            property int gap: 5
            property int column: 5

            currentIndex: root.index

            cellWidth: (root.implicitWidth-5)/column
            cellHeight: (root.implicitWidth-5)/column

            highlightFollowsCurrentItem: true   // <- viewport tracks currentItem
            highlightMoveDuration: 120          // smooth scroll animation (optional)

            function reloadModel() {
                opacity = 0

                Qt.callLater(() => {
                    model = newModel
                    opacity = 1
                })
            }

            model: ScriptModel {
                values: root.searchText.length === 0
                ? [...DesktopEntries.applications.values]
                : Fuzzysort.go(root.searchText,
                [...DesktopEntries.applications.values],
                { key: "name" })
                .map(r => r.obj)
            }

            MouseArea {
                anchors.fill:parent
                onClicked: {
                    if (root.index === itemList.index) {
                        root.exec()
                        Global.get(root.parentRoot.screen).launcherVisibility = false
                    } else {
                        root.parentRoot.selectedIndex = itemList.index
                    }
                }
            }

            delegate: Item {
                id:itemList

                required property DesktopEntry modelData
                required property int index

                implicitHeight: gridview.cellHeight-gridview.gap
                implicitWidth: gridview.cellWidth-gridview.gap

                Rectangle {
                    anchors.fill:parent

                    radius: 10
                    clip:true

                    color: root.index === itemList.index 
                    ? Color.on_secondary
                    : Color.surface_container

                    Behavior on color { CAnim{} }

                    ColumnLayout {
                        anchors.fill:parent
                        anchors.margins: 5
                        IconImage {
                            asynchronous:true
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            Layout.alignment:Qt.AlignCenter
                            source: Quickshell.iconPath(itemList.modelData.icon || "", true)
                        }
                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment:Qt.AlignCenter
                            text: itemList.modelData.name
                            horizontalAlignment: Text.AlignHCenter
                            surface: root.index === itemList.index ? 2 : 1
                            size: 10
                        }
                        Rectangle {
                            Layout.alignment:Qt.AlignCenter
                            implicitWidth: 25
                            implicitHeight: root.index === itemList.index ? 3 : 0
                            color: root.index === itemList.index ? Color.primary : "transparent"
                            radius: 10
                        }
                    }
                }
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
