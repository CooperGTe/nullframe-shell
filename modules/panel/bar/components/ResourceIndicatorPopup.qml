import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import qs.config
import qs.services
import qs.components

import "../components/"

PopoutWindow {
    id:root

    property bool hovered: hover.hovered

    visibility: parent.popupVisibility

    implicitWidth: 260 + (!Config.barOrientation ? -15 : 0)
    implicitHeight: 120 + (!Config.barOrientation ? 15 : 0)

    ItemShadow {

    }
    Rectangle {
        anchors { 
            fill:parent

            margins: 20

            leftMargin: Config.bar.position === 0 ? root.visibility ? 5 : -310
            : (Config.bar.position === 2 ? root.visibility ? 20 : 300
            : 20)
            topMargin: Config.bar.position === 1 ? root.visibility ? 5 : -310
            : (Config.bar.position === 3 ? root.visibility ? 20 : 300
            : 20)
            rightMargin: Config.bar.position === 2 ? root.visibility ? 5 : -310
            : (Config.bar.position === 0 ? root.visibility ? 20 : 300
            : 20)
            bottomMargin: Config.bar.position === 3 ? root.visibility ? 5 : -310
            : (Config.bar.position === 1 ? root.visibility ? 20 : 300
            : 20)
        }

        component NumAnim: NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }

        Behavior on opacity { NumAnim {} }

        Behavior on anchors.leftMargin { NumAnim {} }
        Behavior on anchors.topMargin { NumAnim {} }
        Behavior on anchors.rightMargin { NumAnim {} }
        Behavior on anchors.bottomMargin { NumAnim {} }

        opacity: root.visibility ? 1 : 0
        color: Color.base
        radius:15

        HoverHandler {
            id:hover
            margin:5
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: console.log(hover.hovered, root.popupVisibility)
        }

        RowLayout {
            id:content
            spacing:5
            anchors.margins:5
            anchors.fill:parent
            Rectangle {
                id: "resman"
                Layout.fillHeight: true
                implicitWidth: 80
                color:"transparent"
                state: "resman"
                Image {
                    anchors.fill: parent
                    source: Quickshell.shellDir + "/assets/asset1.png"
                    fillMode: Image.PreserveAspectCrop
                    smooth:true
                    visible: resman.state == "resman"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: resman.state = "resact"
                    }
                }
                ColumnLayout {
                    visible: resman.state == "resact"
                    anchors.fill: parent
                    Text { 
                        text: "どうしたら良い"
                        font.family: "Noto Sans CJK JP"
                        font.bold: true
                        color: Color.primary
                        MouseArea {
                            anchors.fill: parent
                            onClicked: resman.state = "resman"
                        }
                    }
                    Button {
                        text: "Clear Cache"
                        Layout.fillWidth: true
                        implicitHeight: 30
                        background: Rectangle{
                            anchors.fill:parent
                            color: Color.container
                            radius: 12
                        }
                        onClicked: Quickshell.execDetached([
                            Quickshell.shellDir + "/scripts/dropCache.sh"
                        ])
                    }
                    Button {
                        text: "Drop Swap"
                        Layout.fillWidth: true
                        implicitHeight: 30
                        background: Rectangle{
                            anchors.fill:parent
                            color: Color.container
                            radius: 12
                        }
                    }
                }
            }
            Rectangle {
                color: Color.container
                radius:15
                implicitWidth: resourceUsageMeter.implicitWidth + 10 + resourceUsageMeter.spacing
                Layout.fillHeight:true
                ColumnLayout {
                    id:resourceUsageMeter
                    spacing:5
                    anchors.fill: parent
                    anchors.margins:5
                    implicitWidth:35
                    ClippedFilledCircularProgress {
                        size: resourceUsageMeter.implicitWidth
                        Layout.alignment: Qt.AlignHCenter
                        value: ResourceUsage.cpuUsage
                        colPrimary: Color.primary
                        colSecondary: Color.base
                        lineWidth: 3
                        Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                fill: 1
                                icon: "memory"
                                font.pixelSize: 24
                                color: Color.primary
                            }
                        }
                    }
                    ClippedFilledCircularProgress {
                        size: resourceUsageMeter.implicitWidth
                        Layout.alignment: Qt.AlignHCenter
                        value: ResourceUsage.memoryUsedCache / ResourceUsage.memoryTotal
                        colPrimary: "#ffafaf"
                        colSecondary: Color.base
                        lineWidth: 3
                        ClippedFilledCircularProgress {
                            size: resourceUsageMeter.implicitWidth
                            Layout.alignment: Qt.AlignHCenter
                            value: ResourceUsage.memoryUsed / ResourceUsage.memoryTotal
                            colPrimary: Color.primary
                            colSecondary: "transparent"
                            lineWidth: 3
                            Item {
                                anchors.fill: parent
                                MaterialIcon {
                                    anchors.centerIn: parent
                                    fill: 0
                                    icon: "memory_alt"
                                    font.pixelSize: 22
                                    color: Color.primary
                                }
                            }
                        }
                    }
                }
            }
            Rectangle { //swap progressbar
            Layout.fillHeight:true
            implicitWidth:15
            color:Color.container
            radius: 15
            Rectangle {
                width: parent.width
                anchors.bottom: parent.bottom
                height: parent.height  * ResourceUsage.swapUsedPercentage
                color: (ResourceUsage.swapUsed / ResourceUsage.swapTotal) < 0.5 ? "#ff9f9f" : "#ff2020"
                radius: 15
            }
        }
        ColumnLayout {
            Layout.fillHeight:true
            Layout.topMargin:-10
            Layout.bottomMargin:-10
            spacing:-2
            Text{
                text: `CPU USAGE:`
                font.pixelSize:8
                color: Color.primary
            }
            Text {
                text: `${Math.floor(ResourceUsage.cpuUsage * 100)}%`
                color: Color.primary
                font.bold:true
            }
            Text{
                text: `RAM USAGE:`
                font.pixelSize:8
                color: Color.primary
            }
            Text {
                text: `${Math.floor(ResourceUsage.memoryUsed / ResourceUsage.memoryTotal * 100)}%`
                color: Color.primary
                font.bold:true
            }
            Text{
                text: `RAM CACHE:`
                font.pixelSize:8
                color: Color.primary
            }
            Text {
                text: `${Math.floor((ResourceUsage.memoryUsedCache - ResourceUsage.memoryUsed) / ResourceUsage.memoryTotal * 100)}%`
                color: Color.primary
                font.bold:true
            }
            Text{
                text: `SWAP USAGE:`
                font.pixelSize:8
                color: Color.primary
            }
            Text {
                text: `${Math.floor(ResourceUsage.swapUsedPercentage * 100)}%`
                color: Color.primary
                font.bold:true
            }
        }
    }
}
}
