import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Hyprland as Hypr

import qs.services
import qs.components
import qs.config

import "../components/"

Item {
    id:root
    property var window
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: Config.barOrientation ? 30 : resitem.implicitHeight + 10
    implicitWidth: Config.barOrientation ? resitem.implicitWidth + 5 : 30
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

    StyledRect {
        border.width: 1
        border.color: Color.container_highest

        Loader {
            id:resitem
            anchors.fill:parent
            sourceComponent: Config.barOrientation ? horizontal : vertical
            asynchronous: true
        }
        Component {
            id: vertical
            ColumnLayout{
                anchors.horizontalCenter: parent.horizontalCenter
                ColumnLayout{
                    Layout.alignment: Qt.AlignHCenter
                    ClippedFilledCircularProgress {
                        Layout.topMargin: 3
                        size: 24
                        value: ResourceUsage.cpuUsage
                        colPrimary:  ResourceUsage.cpuUsage < 0.9 ? Color.secondary : Color.tertiary
                        colSecondary: Color.container_highest
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
                        colSecondary: Color.container_highest
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
                        : Color.tertiary
                        colSecondary: Color.container_highest
                        lineWidth: 3
                        sweepDegree: 60
                        startAngle: 180
                    }
                }
                ProgressBar {
                    id: pgswap
                    Layout.topMargin: -20 //mergehack
                    Layout.alignment: Qt.AlignHCenter
                    value:ResourceUsage.swapUsed / ResourceUsage.swapTotal
                    implicitWidth:20
                    implicitHeight:5
                    contentItem:ClippingRectangle { 
                        color: "transparent"
                        radius: 4
                        Rectangle {
                            width: pgswap.width  * pgswap.visualPosition
                            height: pgswap.height
                            radius: 4
                            color: (ResourceUsage.swapUsed / ResourceUsage.swapTotal) < 0.8 ? Color.tertiary : Color.error
                        }
                    }
                    background: Rectangle {
                        color: Color.container_highest
                        radius: 4
                    }
                }
            }
        }
        Component {
            id: horizontal
            RowLayout{
                anchors.verticalCenter: parent.verticalCenter
                RowLayout{
                    Layout.alignment: Qt.AlignVCenter
                    ClippedFilledCircularProgress {
                        Layout.leftMargin: 3
                        size: 24
                        value: ResourceUsage.cpuUsage
                        colPrimary:  ResourceUsage.cpuUsage < 0.9 ? Color.surface : Color.tertiary
                        colSecondary: Color.container_highest
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
                        colSecondary: Color.container_highest
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
                        Layout.leftMargin: -24-5//mergehack
                        size: 24
                        value: (ResourceUsage.memoryUsedCache - ResourceUsage.memoryUsed) 
                        / (ResourceUsage.memoryTotal - ResourceUsage.memoryUsed)
                        colPrimary:  ((ResourceUsage.memoryUsedCache - ResourceUsage.memoryUsed) 
                        / (ResourceUsage.memoryTotal - ResourceUsage.memoryUsed)) < 0.5 
                        ? Color.secondary
                        : Color.tertiary
                        colSecondary: Color.container_highest
                        lineWidth: 3
                        sweepDegree: 60
                        startAngle: 180
                    }
                }
                ProgressBar {
                    id: pgswap1
                    Layout.leftMargin: -20 //mergehack
                    Layout.alignment: Qt.AlignHCenter
                    value:ResourceUsage.swapUsed / ResourceUsage.swapTotal
                    implicitWidth:5
                    implicitHeight:20
                    contentItem:ClippingRectangle { 
                        color: "transparent"
                        radius: 4
                        Rectangle {
                            height: pgswap1.height  * pgswap1.visualPosition
                            width: pgswap1.width
                            radius: 4
                            color: (ResourceUsage.swapUsed / ResourceUsage.swapTotal) < 0.8 ? Color.tertiary : Color.error
                        }
                    }
                    background: Rectangle {
                        color: Color.container_highest
                        radius: 4
                    }
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
