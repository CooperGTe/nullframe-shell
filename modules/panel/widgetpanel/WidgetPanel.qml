pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.components
import qs.config

PanelWindow {
    id:root

    property var scope
    property var barRoot
    property bool visibility: false

    WlrLayershell.layer: WlrLayer.Top

    margins {
        left:-10
        right: loader.active ? -10 : -340 + (Config.bar.borderWidth < 3 ? 3 : 0)
        bottom:-10
        top:-10
    }

    anchors.right: true

    color: "transparent"
    implicitHeight: 550; implicitWidth: 340
    exclusiveZone:0

    ItemShadow {}

    Behavior on visibility {
        SequentialAnimation {
            ScriptAction { 
                script: {
                    loader.active = true
                }
            }
            PauseAnimation { 
                duration: 400
            }
            ScriptAction { 
                script: if (!root.visibility) {
                    loader.active = false
                }
            }
        }
    }

    //Drag Handler/Flick Handler
    //didnt vibe code this but i have no fucking idea how dis work
    //fiddling/brute force value make it work o_o?
    Item {
        id: drag

        property bool open: false
        property bool locked: false

        onOpenChanged: if (!open) root.visibility = false

        height: parent.height; width: parent.width

        x: open ? 0 : -10

        Behavior on x {
            SpringAnimation {
                spring: 10
                damping: 0.4
                mass: 1
                epsilon: 0.005  
            }                
        }

        // discard any drag handling that doesn't flick
        Timer {
            id: dragreset
            running: false
            interval:100
            onTriggered: {
                drag.locked = true
                drag.x = 0
            }
        }

        DragHandler {
            target: null
            xAxis.enabled: true
            property real startX: 0

            onActiveChanged: {
                if (active) {
                    startX = drag.x
                    root.visibility = true
                    drag.locked = false
                    dragreset.restart()
                }
                else {
                    if (drag.open) {
                        drag.open = drag.x < drag.width/16
                        if (drag.open) drag.x = 0
                    }
                    else drag.open = drag.x < drag.width/16
                }
                //console.log(drag.open, "widget panel", drag.x, "<", drag.width/16,  drag.x < drag.width/16)
            }

            onTranslationChanged: {
                if (drag.locked) return
                drag.x = Math.max(drag.parent.width - drag.width, Math.min(drag.parent.width, startX + translation.x))
            }
        }
    }

    Loader {
        id:loader

        active:false
        anchors.fill: parent

        sourceComponent: Item {
            id: base

            anchors.fill:parent
            anchors.margins:10


            PopoutShape {
                id:popout
                anchors.right:parent.right
                side:2
                implicitWidth: drag.open ? parent.width : 0
                implicitHeight: parent.height
                baseColor: Config.widgetPanel.floating ? "transparent" : Colors.base

                Rectangle {
                    color: Config.widgetPanel.floating ? Colors.base : "transparent"
                    radius:13

                    implicitHeight:parent.height - 30
                    implicitWidth:base.width - anchors.rightMargin

                    anchors.rightMargin: Config.widgetPanel.floating ? 5 : 0
                    anchors.verticalCenter: parent.verticalCenter

                    WidgetContent {}
                }
            }
        }
    }
    component Anim: NumberAnimation {
        duration: 400
        easing.type: Easing.BezierSpline
        easing.bezierCurve: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
    }
}
