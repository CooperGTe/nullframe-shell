pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

import "components"


PanelWindow {
    id:root
    property var scope
    property var barHug
    property bool sidePanelVisible: false

    WlrLayershell.layer: WlrLayer.Top
    implicitWidth: 40
    implicitHeight: 40
    color: "transparent"
    anchors {
        top: (Config.bar.position === 3) ? false : true
        left: (Config.bar.position === 2) ? false : true
        bottom: (Config.bar.position === 1)? false : true
        right: (Config.bar.position === 0) ? false : true
    }
    Component.onCompleted: console.log(Config.bar.position) 
    Rectangle {
        color: Color.base
        //color: "transparent"
        anchors.fill: parent
        topRightRadius: root.barHug ? 0 : 
            ((Config.bar.position === 0 || Config.bar.position === 3) ? 20 : 0 )
        bottomRightRadius:root.barHug ? 0 : 
            ((Config.bar.position === 0 || Config.bar.position === 1) ? 20 : 0 )
        topLeftRadius: root.barHug ? 0 : 
            ((Config.bar.position === 2 || Config.bar.position === 3) ? 20 : 0 )
        bottomLeftRadius:root.barHug ? 0 : 
            ((Config.bar.position === 2 || Config.bar.position === 1) ? 20 : 0 )
        anchors {
            topMargin: root.barHug ? 0 : (!Config.barOrientation ? 5 : 0 )
            bottomMargin: root.barHug ? 0 : (!Config.barOrientation ? 5 : 0 )
            leftMargin: root.barHug ? 0 : (Config.barOrientation ? 5 : 0 )
            rightMargin: root.barHug ? 0 : (Config.barOrientation ? 5 : 0 )
        }
        component ColorAnim: ColorAnimation { duration: 200; easing.type: Easing.InOutQuad }
        component NumAnim: NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        
        Behavior on color { ColorAnim{} }
        Behavior on topRightRadius { NumAnim{} }
        Behavior on bottomRightRadius { NumAnim{} }
        Behavior on topLeftRadius { NumAnim{} }
        Behavior on bottomLeftRadius { NumAnim{} }
        Behavior on anchors.topMargin { NumAnim{} }
        Behavior on anchors.bottomMargin { NumAnim{} }
        Behavior on anchors.leftMargin { NumAnim{} }
        Behavior on anchors.rightMargin { NumAnim{} }
        //Dynamic Loader
        Loader {
            anchors.fill: parent
            sourceComponent: Config.barOrientation ? horizontalLayout : verticalLayout
        }
        Component {
            id: verticalLayout
            Column {
                anchors.fill: parent
                // TOP
                ColumnLayout {
                    anchors.top: parent.top
                    anchors.margins: root.barHug ? 10 : 20
                    Behavior on Layout.topMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    PanelButton {
                        id: panelbtn
                        onClicked: scope.sidePanelVisible = !scope.sidePanelVisible
                    }
                    Tray {}
                    ResourceIndicator { window: root }
                }
                // CENTER
                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.margins: root.barHug ? 10 : 20
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    Layout.fillHeight: true
                    Workspaces {}
                    Mpris {}
                }
                // BOTTOM
                ColumnLayout {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: root.barHug ? 10 : 20
                    Behavior on Layout.bottomMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    ControlsGroup {}
                    Rectangle {
                        Layout.bottomMargin: 3
                        Layout.leftMargin: 5
                        Layout.rightMargin: 5
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Color.container
                    }
                    BatteryIndicator {}
                    Clock {}
                }
            }
        }
        Component {
            id: horizontalLayout
            RowLayout {
                anchors.fill: parent
                // LEFT
                RowLayout {
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.leftMargin: root.barHug ? 10 : 20
                    Behavior on Layout.leftMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    PanelButton {
                        id: panelbtn
                        onClicked: scope.sidePanelVisible = !scope.sidePanelVisible
                    }
                    Tray {}
                    ResourceIndicator { 
                        window: root 
                    }
                }
                // CENTER
                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Workspaces {}
                }
                Item { Layout.fillWidth: true }   // spacer
                // RIGHT
                RowLayout {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.rightMargin: root.barHug ? 10 : 20
                    Behavior on Layout.rightMargin {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                    Mpris {}
                    ControlsGroup {}
                    Rectangle {
                        Layout.bottomMargin: Config.barOrientation ? 5 : 3
                        Layout.topMargin: Config.barOrientation ? 5 : 0
                        Layout.leftMargin: Config.barOrientation ? 0 : 5
                        Layout.rightMargin: Config.barOrientation ? 3 : 5
                        Layout.fillHeight: true
                        implicitWidth: 1
                        color: Color.container
                    }
                    BatteryIndicator {}
                    Clock {}
                }
            }
        }
    }
}
