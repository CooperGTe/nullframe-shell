pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components

import "modules"
import "../"

PanelWindow {
    id:root

    property var scope
    property var barHug
    property bool controlPanelVisible: false
    property bool floating: Config.bar.floating
    property real shadowRange: 16

    WlrLayershell.layer: WlrLayer.Top
    exclusiveZone:Config.barTotalWidth
    color: "transparent"

    anchors {
        top:  true
        left: true
        bottom: true
        right: true
    }

    // Shadow Graphics Quirkyness fix (shadow render broke when size changing)
    // [start]
    property bool orientation: Config.barOrientation
    onOrientationChanged: {
        shadowRefresh.running = true
    }
    ItemShadow {
        id:shadow

        spread: 2
        size:1
        enabled: true
        range:root.shadowRange
    }
    Timer {
        id:shadowRefresh

        interval: 100

        repeat:false
        running: false

        onTriggered: {
            shadow.update()
        }
    }
    // [end]

    mask: Region {
        x: Config.bar.position === 2 ? root.width - Config.barTotalWidth : 0
        y: Config.bar.position === 3 ? root.height - Config.barTotalWidth : 0
        width: !Config.barOrientation ? Config.barTotalWidth : root.width
        height: Config.barOrientation ? Config.barTotalWidth : root.height 
    }

    Border {
        hug: root.barHug
    }

    Rectangle {
        id: bar

        color: Color.base

        anchors {
            leftMargin: (Config.bar.position === 0 && root.floating) ? (root.barHug ? 0 : 5) : 0
            topMargin: (Config.bar.position === 1 && root.floating) ? (root.barHug ? 0 : 5) : 0
            rightMargin: (Config.bar.position === 2 && root.floating) ? (root.barHug ? 0 : 5) : 0
            bottomMargin: (Config.bar.position === 3 && root.floating) ? (root.barHug ? 0 : 5) : 0
        }

        implicitHeight: (Config.barOrientation) ? Config.barTotalWidth
        : scope.modelData.height - (root.barHug ? 0 : Config.bar.edgeMargin * 2)
        implicitWidth: (!Config.barOrientation) ? Config.barTotalWidth 
        : scope.modelData.width - (root.barHug ? 0 : Config.bar.edgeMargin * 2)

        // conditionally setting anchors like that can cause binding instability, fix: 
        states: [
            State {
                name: "left"

                when: Config.bar.position === 0
                AnchorChanges {
                    target: bar

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: undefined
                }
            },
            State {
                name: "top"

                when: Config.bar.position === 1
                AnchorChanges {
                    target: bar

                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: undefined
                }
            },
            State {
                name: "right"

                when: Config.bar.position === 2
                AnchorChanges {
                    target: bar

                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: undefined
                }
            },
            State {
                name: "bottom"

                when: Config.bar.position === 3
                AnchorChanges {
                    target: bar

                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: undefined
                }
            }
        ]

        transitions: Transition {
            AnchorAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        topRightRadius: root.barHug ? 0 
        : ((Config.bar.position === 0 || Config.bar.position === 3) ? 20 
        : root.floating ? 20 : 0)
        bottomRightRadius: root.barHug ? 0 
        : ((Config.bar.position === 0 || Config.bar.position === 1) ? 20 
        : root.floating ? 20 : 0)
        topLeftRadius: root.barHug ? 0 
        : ((Config.bar.position === 2 || Config.bar.position === 3) ? 20 
        : root.floating ? 20 : 0)
        bottomLeftRadius: root.barHug ? 0 
        : ((Config.bar.position === 2 || Config.bar.position === 1) ? 20 
        : root.floating ? 20 : 0)

        component ColorAnim: ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
        component NumAnim: NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        
        Behavior on color { ColorAnim{} }

        Behavior on topRightRadius { NumAnim{} }
        Behavior on bottomRightRadius { NumAnim{} }
        Behavior on topLeftRadius { NumAnim{} }
        Behavior on bottomLeftRadius { NumAnim{} }

        Behavior on anchors.leftMargin { NumAnim{} }
        Behavior on anchors.topMargin { NumAnim{} }
        Behavior on anchors.rightMargin { NumAnim{} }
        Behavior on anchors.bottomMargin { NumAnim{} }

        Behavior on implicitHeight { NumAnim{} }
        Behavior on implicitWidth { NumAnim{} }

        // ONLOAD ANIMATION PATCH
        // [start]
        opacity: 0
        Component.onCompleted: loadtimer.start()
        
        property int pos: Config.bar.position
        onPosChanged: {
            bar.opacity = 0
            loadtimer.start()
        }

        Timer {
            id: loadtimer

            repeat: false
            running: false
            interval: 400
            onTriggered: bar.opacity = 1
        }
        onOpacityChanged: {
            if (opacity === 1) {
                fadeIn.start()
            }
        }

        NumberAnimation {
            id: fadeIn

            target: bar
            property: "opacity"
            from: 0
            to: 1
            duration: 200
            easing.type: Easing.InOutQuad
        }
        // [end]

        component BarSeparator: Rectangle {
            color: Color.container
            
            implicitWidth: !Config.barOrientation ? 30 : 1
            implicitHeight: Config.barOrientation ? 30 : 1

            anchors.horizontalCenter: !Config.barOrientation ? parent.horizontalCenter : undefined
            anchors.verticalCenter: Config.barOrientation ? parent.verticalCenter : undefined
        }
        //Dynamic Loader
        Loader {
            id:loader
            anchors.fill: parent
            sourceComponent: Config.barOrientation ? horizontalLayout : verticalLayout
            asynchronous: true
        }

        Component {
            id: verticalLayout
            Item {
                anchors.fill: parent

                // Start
                ColumnLayout {
                    spacing: Config.barSpacing

                    anchors.top: parent.top
                    anchors.horizontalCenter:parent.horizontalCenter
                    anchors.topMargin: root.barHug ? 10 : 20

                    Behavior on anchors.topMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    PanelButton {
                        id: panelbtn
                        onClicked: scope.controlPanelVisible = !scope.controlPanelVisible
                    }

                    Tray {}

                    ResourceIndicator { window: root }
                }

                // CENTER
                ColumnLayout {
                    spacing: Config.barSpacing

                    anchors.centerIn: parent

                    Workspaces {}

                    Mpris {}
                }

                // End
                ColumnLayout {
                    spacing: Config.barSpacing

                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter:parent.horizontalCenter
                    anchors.bottomMargin: root.barHug ? 10 : 20

                    Behavior on anchors.bottomMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    ControlsGroup {}

                    BarSeparator {}

                    BatteryIndicator {}

                    Clock {}
                }
            }
        }
        Component {
            id: horizontalLayout
            Item {
                id: horizontalBar
                anchors.fill: parent

                // Start
                RowLayout {

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: root.barHug ? 10 : 0

                    Behavior on Layout.leftMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    PanelButton {
                        id: panelbtn
                        onClicked: scope.controlPanelVisible = !scope.controlPanelVisible
                    }

                }

                // CENTER
                RowLayout {
                    anchors.centerIn: parent

                    Clock {}

                    ResourceIndicator { 
                        window: root 
                    }

                    Workspaces {}

                    Mpris {}

                }
                // RIGHT
                RowLayout {
                    anchors.right:parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: root.barHug ? 10 : 5

                    Behavior on Layout.rightMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }

                    Tray {}

                    BarSeparator {}

                    BatteryIndicator {}

                    ControlsGroup {}
                }
            }
        }
    }
}
