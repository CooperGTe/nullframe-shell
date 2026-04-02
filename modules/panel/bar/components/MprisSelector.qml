import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

import qs.config
import qs.components
import qs.services

Rectangle {
    id: root
    property string icon
    property string text
    property bool reset: false
    property var stack
    property var stackTarget
    property var mData
    color: Color.container
    radius: 5
    implicitHeight: 20
    Layout.fillWidth: true
    Layout.rightMargin: 10
    MouseArea {
        anchors.fill:parent
        onClicked: {
            root.stack.replace(root.stackTarget)
            if (!root.reset) MprisController.setActivePlayer(root.mData)
            if (root.reset) MprisController.resetAutoPlayer()
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
            else if (!root.reset && MprisController.lock) (MprisController.trackedPlayer === root.mData)
            else false
            Layout.leftMargin: 10
        }
    }
}

