import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland as Hypr

import qs.services
import qs.modules.common
import qs.config

import "."

Item {
    id:root
    property var window
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: resitem.implicitHeight + 10
    implicitWidth: 40
    property bool hover: true   
    property bool popupVisibility: root.hover ? hover.hovered || popup.hovered : false
    
    Hypr.HyprlandFocusGrab {
        id: grab
        windows: [ window, popup ]
        active: if (!root.hover) root.popupVisibility
        onActiveChanged: {
            if (!grab.active) {
                if (!hover) root.popupVisibility = false
            }
        }
    }
    property real wsch: Hyprland.activeWorkspace
    onWschChanged: {
        if (!hover) root.popupVisibility = false
    }

    Rectangle {
        anchors.fill:parent
        color: Color.container
        border.width: 1
        border.color: Color.container_high
        radius:30
        anchors.leftMargin:5
        anchors.rightMargin:5

        ColumnLayout{
            id:resitem
            anchors.horizontalCenter: parent.horizontalCenter
            ColumnLayout{
                Layout.alignment: Qt.AlignHCenter
                ClippedFilledCircularProgress {
                    Layout.topMargin: 3
                    size: 24
                    value: ResourceUsage.cpuUsage
                    colPrimary:  ResourceUsage.cpuUsage < 0.9 ? Color.surface : "#ffafaf"
                    colSecondary: Color.container_high
                    lineWidth: 3
                    Item {
                        anchors.fill: parent
                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: "memory"
                            fill:0
                            font.pixelSize: 16
                            color: Color.surface
                        }
                    }
                }
                ClippedFilledCircularProgress {
                   size: 24
                   value: ResourceUsage.memoryUsed / ResourceUsage.memoryTotal
                   colPrimary:  Color.secondary
                   colSecondary: Color.container_high
                   lineWidth: 3
                   sweepDegree: 270
                   Item {
                       anchors.fill: parent
                       MaterialIcon {
                           anchors.centerIn: parent
                           icon: "memory_alt"
                           fill:0
                           font.pixelSize: 14
                           color: Color.surface
                       }
                   }
                }
                ClippedFilledCircularProgress {
                    Layout.topMargin: -24-10 //mergehack
                    size: 24
                    value: (ResourceUsage.memoryUsedCache - ResourceUsage.memoryUsed) 
                        / (ResourceUsage.memoryTotal - ResourceUsage.memoryUsed)
                    colPrimary:  ((ResourceUsage.memoryUsedCache - ResourceUsage.memoryUsed) 
                        / (ResourceUsage.memoryTotal - ResourceUsage.memoryUsed)) < 0.5 
                        ? Color.secondary
                        : Color.error
                    colSecondary: Color.container_high
                    lineWidth: 3
                    sweepDegree: 60
                    startAngle: 180
                }
            }
            ProgressBar {
                Layout.topMargin: -10 //mergehack
                Layout.alignment: Qt.AlignHCenter
                value:ResourceUsage.swapUsed / ResourceUsage.swapTotal
                implicitWidth:20
                implicitHeight:5
                contentItem: Rectangle {
                    width: parent.width * parent.visualPosition
                    height: parent.height
                    color: (ResourceUsage.swapUsed / ResourceUsage.swapTotal) < 0.5 ? "#ff9f9f" : "#ff2020"
                    radius: 4
                }
                background: Rectangle {
                    color: Color.container_high
                    radius: 4
                }
            }
        }
        ResourceIndicatorPopup {
            id:popup
            parent: root
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled:true
        onClicked: {
            if (!root.hover) root.popupVisibility = !root.popupVisibility
            console.log("clicked", root.popupVisibility)
        }
    }
    HoverHandler {
        id:hover
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: console.log(hover.hovered, root.popupVisibility)
    }
}
