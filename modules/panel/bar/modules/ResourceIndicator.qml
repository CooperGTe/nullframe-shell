import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets

import qs.services
import qs.components
import qs.config

import "../components/"

Item {
    id:root

    property var window
    property bool popupVisibility: hover.hovered || popup.hovered

    Layout.alignment: Qt.AlignHCenter

    implicitHeight: Config.barOrientation ? Config.barTotalWidth : 82
    implicitWidth: Config.barOrientation ? 82 : Config.barTotalWidth
    
    StyledRect {
        anchors.fill: parent
        border.width: 1
        border.color: Color.container_highest
        anchors.margins: Config.barMargin

        Loader {
            id:resitem
            anchors.fill:parent
            //?????
            anchors.topMargin: !Config.barOrientation ? 3 : 0
            anchors.leftMargin: Config.barOrientation ? 3 : 0
            sourceComponent: Config.barOrientation ? horizontal : vertical
            asynchronous: true
        }

        Component {
            id: vertical

            Column{
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5

                ClippedFilledCircularProgress {
                    anchors.horizontalCenter:parent.horizontalCenter

                    size: 24
                    value: ResourceUsage.cpuUsage
                    colPrimary:  ResourceUsage.cpuUsage < 0.9 ? Color.secondary : Color.on_surface
                    colSecondary: Color.container_highest
                    lineWidth: 3
                    Item {
                        anchors.fill: parent
                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: "memory"
                            fill:0
                            font.pixelSize: 16
                            color: Color.secondary
                        }
                    }
                }
                Item {
                    anchors.horizontalCenter:parent.horizontalCenter

                    implicitHeight: 24
                    implicitWidth: 24
                    ClippedFilledCircularProgress {
                        size: 24
                        value: ResourceUsage.memoryUsed / ResourceUsage.memoryTotal
                        colPrimary:  Color.secondary
                        colSecondary: Color.on_secondary
                        lineWidth: 3
                        sweepDegree: 270
                        Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: "memory_alt"
                                fill:0
                                font.pixelSize: 14
                                color: Color.secondary
                            }
                        }
                    }
                    ClippedFilledCircularProgress {
                        size: 24
                        value: (ResourceUsage.memoryUsedCache - ResourceUsage.memoryUsed) 
                        / (ResourceUsage.memoryTotal - ResourceUsage.memoryUsed)
                        colPrimary:  ((ResourceUsage.memoryUsedCache - ResourceUsage.memoryUsed) 
                        / (ResourceUsage.memoryTotal - ResourceUsage.memoryUsed)) < 0.5 
                        ? Color.secondary
                        : Color.on_surface
                        colSecondary: Color.container_highest
                        lineWidth: 3
                        sweepDegree: 60
                        startAngle: 180
                    }
                }
                ProgressBar {
                    id: pgswap

                    anchors.horizontalCenter:parent.horizontalCenter

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
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                ClippedFilledCircularProgress {
                    anchors.verticalCenter: parent.verticalCenter

                    size: 24
                    value: ResourceUsage.cpuUsage
                    colPrimary:  ResourceUsage.cpuUsage < 0.9 ? Color.primary : Color.tertiary
                    colSecondary: Color.container_highest
                    lineWidth: 3
                    Item {
                        anchors.fill: parent
                        MaterialIcon {
                            anchors.centerIn: parent
                            icon: "memory"
                            fill:0
                            font.pixelSize: 16
                            color: Color.primary
                        }
                    }
                }
                Item {
                    anchors.verticalCenter: parent.verticalCenter

                    implicitHeight: 24
                    implicitWidth: 24
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
                                color: Color.primary
                            }
                        }
                    }
                    ClippedFilledCircularProgress {
                        anchors.verticalCenter: parent.verticalCenter
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
                    anchors.verticalCenter: parent.verticalCenter
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

    HoverHandler {
        id:hover
        cursorShape: Qt.PointingHandCursor
        onHoveredChanged: console.log(hover.hovered, root.popupVisibility)
    }
}
