import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

import qs.config
import qs.services
import qs.modules.common

PopupWindow {
    id:root
    property var parent
    property bool hovered: hover.hovered
    property bool visibility: parent.popupVisibility
    Behavior on visibility {
        SequentialAnimation {
            ScriptAction { 
                script: root.visible = true
            }
            PauseAnimation { 
                duration: 400
            }
            ScriptAction { 
                script: if (!visibility) root.visible = false
            }
        }
    }
    anchor.item: parent
    anchor.edges: Edges.Left
    anchor.gravity: Edges.Right
    anchor.margins{
        left: 35
        right: 0
        top:-20
        bottom: -20

    }
    implicitWidth: content.implicitWidth + 20+20 //margin + spacing
    implicitHeight: content.implicitHeight + 30+40

    visible: false
    color:"transparent"
    ItemShadow{}
    Rectangle {
        anchors.fill:parent
        anchors.leftMargin: root.visibility ? 5 : -310
        anchors.rightMargin: root.visibility ? 20 : 300
        opacity: root.visibility ? 1 : 0
        anchors.margins:20

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on anchors.rightMargin {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }
        Behavior on anchors.leftMargin {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

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
                        color: Color.surface
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
                        colPrimary: Color.surface
                        colSecondary: Color.base
                        lineWidth: 3
                        Item {
                            anchors.fill: parent
                            MaterialIcon {
                                anchors.centerIn: parent
                                fill: 1
                                icon: "memory"
                                font.pixelSize: 24
                                color: Color.surface
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
                            colPrimary: Color.surface
                            colSecondary: "transparent"
                            lineWidth: 3
                            Item {
                                anchors.fill: parent
                                MaterialIcon {
                                    anchors.centerIn: parent
                                    fill: 0
                                    icon: "memory_alt"
                                    font.pixelSize: 22
                                    color: Color.surface
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
                color: Color.surface
            }
            Text {
                text: `${Math.floor(ResourceUsage.cpuUsage * 100)}%`
                color: Color.surface
                font.bold:true
            }
            Text{
                text: `RAM USAGE:`
                font.pixelSize:8
                color: Color.surface
            }
            Text {
                text: `${Math.floor(ResourceUsage.memoryUsed / ResourceUsage.memoryTotal * 100)}%`
                color: Color.surface
                font.bold:true
            }
            Text{
                text: `RAM CACHE:`
                font.pixelSize:8
                color: Color.surface
            }
            Text {
                text: `${Math.floor((ResourceUsage.memoryUsedCache - ResourceUsage.memoryUsed) / ResourceUsage.memoryTotal * 100)}%`
                color: Color.surface
                font.bold:true
            }
            Text{
                text: `SWAP USAGE:`
                font.pixelSize:8
                color: Color.surface
            }
            Text {
                text: `${Math.floor(ResourceUsage.swapUsedPercentage * 100)}%`
                color: Color.surface
                font.bold:true
            }
        }
    }
}
}
