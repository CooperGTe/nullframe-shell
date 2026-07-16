pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import qs.config
import qs.components
import qs.modules


PanelWindow {
    id:root

    property var scope
    property var screen
    property var visibility

    property int selectedIndex: 0
    property int modeIndex: 0
    property bool focusStealer: false
    property bool allowUngrab: true
    property bool listview: true

    WlrLayershell.keyboardFocus : root.visibility 
        ? (root.focusStealer ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand)
        : WlrKeyboardFocus.None
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "launcher"

    Timer {
        id:focusstealer
        interval:100
        running: false
        onTriggered: {
            root.focusStealer = false
        }
    }

    anchors.bottom: true
    margins.bottom: Config.dock.floating ? 40 + Config.bar.borderWidth + 2 : 40 + Config.bar.borderWidth

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    onVisibilityChanged: {
        if (root.visibility) {
            search.searchPointer.focus = true

            //focus steal
            root.focusStealer = true
            focusstealer.running = true

            grab.active = true
        }
    }

    implicitHeight: 400 + 40 //shadow
    implicitWidth: 400 + 40 //shadow
    color: "transparent"

    //mask: Region { item:column }

    HyprlandFocusGrab {
        id: grab
        active: root.visibility
        windows: [ root ]
        onActiveChanged: {
            if (!grab.active && root.allowUngrab) {
                Global.get(root.screen).launcherVisibility = false
            }
        }
    }

    ItemShadow {}

    ColumnLayout {
        id: column

        anchors.fill:parent
        anchors.margins:20


        Item { Layout.fillHeight: true }

        // --- EnterExit Animation ---
        
        anchors.bottomMargin: root.visibility ? 0 : -20
        opacity: root.visibility ? 1 : 0

        Behavior on anchors.bottomMargin { Anim{} }
        Behavior on opacity { Anim{} }
        Behavior on implicitHeight { Anim{} }

        LauncherContent {
            id: launcherContent

            parentRoot: root
            //model:
            index: root.selectedIndex
            searchText: search.searchPointer.text
            visibility: root.visibility
        }

        SearchBox {
            id:search

            parentRoot: root
            launcherContentPointer: launcherContent
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Down) {
                event.accepted = true;
                if (launcherContent.listcount > 0) {
                    root.selectedIndex = (root.selectedIndex + 1) % launcherContent.listcount;
                }
            } else if (event.key === Qt.Key_Up) {
                event.accepted = true;
                if (launcherContent.listcount > 0) {
                    root.selectedIndex = (root.selectedIndex - 1 + launcherContent.listcount) % launcherContent.listcount;
                }
            }  else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
            && event.modifiers & Qt.ControlModifier) {

                event.accepted = true

                if (launcherContent.searchText !== "") {
                    root.webSearch(root.searchText)
                    Global.get(root.screen).launcherVisibility = false
                }
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true;
                if (root.selectedIndex >= 0) {
                    launcherContent.exec()
                    Global.get(root.screen).launcherVisibility = false
                }
            } else if (event.key === Qt.Key_Escape) {
                event.accepted = true;
                Global.get(root.screen).launcherVisibility = false
            } else if (event.key === Qt.Key_Backtab) {
                event.accepted = true;

                root.modeIndex > 0 ? root.modeIndex -= 1 : root.modeIndex = 4
            } else if (event.key === Qt.Key_Tab) {
                event.accepted = true;

                root.modeIndex < 4 ? root.modeIndex += 1 : root.modeIndex = 0
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
