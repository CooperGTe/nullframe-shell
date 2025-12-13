pragma ComponentBehavior: Bound
//@ pragma IconTheme Papirus-Dark

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: root

    property var scope
    property bool visibility
    property bool calc: false
    property real selectedIndex: 0

    onVisibilityChanged: {
        console.log(visibility)
        if (root.visibility) grab.active = true
        if (!root.visibility) grab.active=false
    }
    onSelectedIndexChanged: {
        list.positionViewAtIndex(selectedIndex, ListView.Center)
    }

    
    function webSearch(q) {
        const url = q.trim()

        const domainRegex = /^[a-z0-9.-]+\.[a-z]{2,}(\/.*)?$/i

        if (domainRegex.test(url)) {
            // direct navigation
            Qt.openUrlExternally("https://" + url)
        } else {
            // search query
            Qt.openUrlExternally(
                "https://duckduckgo.com/?q=" + encodeURIComponent(q)
            )
        }
        Quickshell.execDetached({ command: ["bash","-c","hyprctl dispatch focuswindow 'class:^(zen)$'"] }); 
    }


    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    color: "transparent"

    implicitWidth: 450
    implicitHeight: 400

    mask: Region { item:windowbox }

    //cool shit
    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
    }
    component CAnim: ColorAnimation { 
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
    }

    GlobalShortcut {
        name: "launcher"
        onPressed: {
            root.WlrLayershell.keyboardFocus= WlrKeyboardFocus.None
            grab.active=false
            root.scope.launcherVisible = false
        }
    }
    Item {
        Component.onCompleted: {
            parent.layer.enabled = true;
            parent.layer.effect = effectComponent;
        }

        Component {
            id: effectComponent
            MultiEffect {
                shadowEnabled: true
                shadowOpacity: 1
                shadowColor: "black"
                shadowBlur: 1
                shadowScale: 1
            }
        }
    }
    HyprlandFocusGrab {
        id: grab
        windows: [ root ]
        onActiveChanged: {
            if (!grab.active) {
                scope.launcherVisible = false
            }
        }
    }
    Rectangle { 
        id: windowbox
        color: Color.base
        border.width:1
        border.color: Color.container
        radius: 20
        implicitWidth:root.implicitWidth-40
        implicitHeight: search.text !== "" ? root.implicitHeight-40 : 75
        Behavior on implicitHeight { Anim {} }
        anchors.margins:20

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Down) {
                event.accepted = true;
                if (list.count > 0) {
                    root.selectedIndex = (root.selectedIndex + 1) % list.count;
                }
            } else if (event.key === Qt.Key_Up) {
                event.accepted = true;
                if (list.count > 0) {
                    root.selectedIndex = (root.selectedIndex - 1 + list.count) % list.count;
                }
            }  else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            && event.modifiers & Qt.ControlModifier) {

                event.accepted = true

                if (search.text !== "") {
                    root.webSearch(search.text)
                    root.scope.launcherVisible = false
                }
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true;
                if (selectedIndex >= 0) {
                    list.model.values[root.selectedIndex].execute()
                    root.scope.launcherVisible = false
                }
            } else if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                root.scope.launcherVisible = false
            }
        }
        ColumnLayout {
            anchors.fill:parent
            anchors.margins:10
            TextField {
                id: search
                focus: root.visibility

                implicitHeight: 30
                Layout.fillWidth:true
                background: Rectangle {
                    color: search.text !== "" ? Color.container : "transparent"
                    radius:10
                    border.width:1
                    border.color: search.text !== "" ? Color.container_high : "transparent"
                    Behavior on border.color { CAnim {} }
                    Behavior on color { CAnim {} }

                }

                placeholderText: "Type to search"
            }
            
            Item {
                implicitHeight: (root.calc && search.text !== "") ? 30 : 0
                Behavior on implicitHeight { Anim {} }
                Layout.fillWidth: true
                clip:true
                Text {
                    function calc(expr) {
                        try {
                            if (expr !=="")root.calc = true
                            return eval(expr)
                        } catch (e) {
                            root.calc = false
                            return ""
                        }
                    }
                    text: "Result: " + calc(search.text)
                    color: Color.surface
                    font.pixelSize:12
                    anchors.verticalCenter:parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                }
            }
            ListView {
                id:list
                Layout.fillHeight: true
                Layout.fillWidth: true
                clip: true

                function fuzzyScore(text, query) {
                    text = text.toLowerCase();
                    query = query.toLowerCase();

                    let score = 0;

                    if (text.startsWith(query)) score += 100;

                    for (const w of text.split(/\s+/)) {
                        if (w.startsWith(query)) score += 50;
                    }

                    let ti = 0;
                    for (let qi = 0; qi < query.length; qi++) {
                        const q = query[qi];
                        let found = false;
                        while (ti < text.length) {
                            if (text[ti] === q) {
                                score += 2;
                                ti++;
                                found = true;
                                break;
                            }
                            ti++;
                        }
                        if (!found) score -= 1;
                    }

                    return score;
                }

                model: ScriptModel {
                    values: [...DesktopEntries.applications.values]
                    .sort((a, b) => list.fuzzyScore(b.name, search.text) -
                    list.fuzzyScore(a.name, search.text))
                }
                delegate: Rectangle {
                    id:itemList
                    required property DesktopEntry modelData
                    required property int index
                    implicitHeight:40
                    radius: 10
                    implicitWidth: ListView.view.width
                    
                    color: root.selectedIndex === index ? Color.container : "transparent"
                    RowLayout {
                        anchors.fill:parent
                        anchors.margins: 5
                        IconImage {
                            asynchronous:true
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            source: Quickshell.iconPath(itemList.modelData.icon || "", true)
                        }
                        ColumnLayout {
                            spacing:0
                            Text {
                                Layout.fillWidth: true
                                text: itemList.modelData.name
                                horizontalAlignment: Text.AlignLeft
                                color: Color.surface
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: itemList.modelData.comment === ""?false:true
                                text: itemList.modelData.comment
                                horizontalAlignment: Text.AlignLeft
                                font.pixelSize:8
                                color: Color.surface_mid
                            }
                        }
                    }
                }
            }
            Rectangle {
                Layout.fillWidth:true
                Layout.topMargin:search.text !== "" ? 0 : -30
                implicitHeight:1
                color: Color.container
            }

            Item {
                Layout.fillWidth:true
                implicitHeight:20
                Layout.topMargin:search.text !== "" ? 0 : -15
                Behavior on Layout.topMargin { Anim {} }
                RowLayout {
                    Rectangle {
                        color: Color.container
                        implicitWidth:20
                        implicitHeight:20
                        radius:5
                        Text {
                            anchors.centerIn:parent
                            text: "↩"
                            color: Color.surface
                        }
                    }
                    Text {
                        text: "Action"
                        color: Color.surface
                    }
                    Rectangle {
                        color: Color.container
                        implicitWidth:20
                        implicitHeight:20
                        radius:5
                        Text {
                            anchors.centerIn:parent
                            text: "⌃"
                            color: Color.surface
                        }
                    }
                    Rectangle {
                        color: Color.container
                        implicitWidth:20
                        implicitHeight:20
                        radius:5
                        Text {
                            anchors.centerIn:parent
                            text: "↩"
                            color: Color.surface
                        }
                    }
                    Text {
                        text: "Search/Open In Browser"
                        color: Color.surface
                    }

                }
            }
        }
    }
}
