import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.modules.common

Item {
    id:root
    Layout.alignment: Qt.AlignHCenter
    implicitHeight: resitem.implicitHeight + 10
    implicitWidth: 40

    
    property bool popup: false
    property bool hoverPopup: true
    property bool animPopup: false

    Rectangle {
        anchors.fill:parent
        color: "#12131F"
        radius:30
        anchors.leftMargin:5
        anchors.rightMargin:5

        ColumnLayout{
            id:resitem
            anchors.horizontalCenter: parent.horizontalCenter
            ColumnLayout{
                Layout.alignment: Qt.AlignHCenter
                MaterialIcon{
                    icon: "memory"
                    Layout.alignment: Qt.AlignCenter
                    font.pixelSize: 16
                    fill:0
                    color: "#DFDFFF"
                }
                ProgressBar {
                    value: ResourceUsage.cpuUsage
                    implicitWidth:18
                    implicitHeight:5
                    contentItem: Rectangle {
                        width: parent.width * parent.visualPosition
                        height: parent.height
                        color: ResourceUsage.cpuUsage < 0.9 ? "#dfdfff" : "#ffafaf"
                        radius: 4
                    }
                }
            }
            ColumnLayout{
                Layout.alignment: Qt.AlignHCenter
                MaterialIcon{
                    icon: "memory_alt"
                    font.pixelSize: 16
                    Layout.bottomMargin: -5//patch
                    fill:0
                    color: "#DFDFFF"
                }
                Item {
                    implicitWidth:18
                    implicitHeight:5
                    ProgressBar {
                        value:ResourceUsage.memoryUsedCache / ResourceUsage.memoryTotal
                        anchors.fill:parent
                        contentItem: Rectangle {
                            width: parent.width * parent.visualPosition
                            height: parent.height
                            color: (ResourceUsage.memoryUsedCache / ResourceUsage.memoryTotal) < 0.9 ? "#6f8f6f" : "#ff7f7f"
                            radius: 4
                        }
                    }
                    ProgressBar {
                        value:ResourceUsage.memoryUsed / ResourceUsage.memoryTotal
                        anchors.fill:parent
                        background: Rectangle { color: "transparent" }
                        contentItem: Rectangle {
                            width: parent.width * parent.visualPosition
                            height: parent.height
                            color: (ResourceUsage.memoryUsed / ResourceUsage.memoryTotal) < 0.9 ? "#dfdfff" : "#ffafaf"
                            radius: 4
                        }
                    }
                }
                ProgressBar {
                    value:ResourceUsage.swapUsed / ResourceUsage.swapTotal
                    implicitWidth:18
                    implicitHeight:5
                    contentItem: Rectangle {
                        width: parent.width * parent.visualPosition
                        height: parent.height
                        color: (ResourceUsage.swapUsed / ResourceUsage.swapTotal) < 0.5 ? "#ff9f9f" : "#ff2020"
                        radius: 4
                    }
                }
            }
        }
        Timer {
            id: hideTimer
            interval: 350
            onTriggered: root.popup = false,root.hoverPopup = true, resman.state = "resman"
        }
        Timer {
            id: animTimer
            interval: 50
            onTriggered: root.animPopup = false
        }
        PopupWindow {
            anchor.item: root
            anchor.edges: Edges.Left
            anchor.gravity: Edges.Right
            anchor.margins{
                left: 40
                right: 0
                top:-20
                bottom: -20

            }
            implicitWidth: content.implicitWidth + 20+20 //margin + spacing
            implicitHeight: resitem.implicitHeight + 30+40

            visible: root.popup
            color:"transparent"
            ItemShadow{}
            Rectangle {
                anchors.fill:parent
                anchors.leftMargin: animPopup ? 5 : -310
                anchors.rightMargin: animPopup ? 20 : 300
                opacity: root.animPopup ? 1 : 0
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

                color: "#080812"
                radius:15
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
                                color: "#dfdfff"
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
                                    color: "#12131F"
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
                                    color: "#12131F"
                                    radius: 12
                                }
                            }
                        }
                    }
                    Rectangle {
                        color: "#12131F"
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
                                colPrimary: "#DFDFFF"
                                colSecondary: "#080812"
                                lineWidth: 3
                                Item {
                                    anchors.fill: parent
                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        fill: 1
                                        icon: "memory"
                                        font.pixelSize: 24
                                        color: "#DFDFFF"
                                    }
                                }
                            }
                            ClippedFilledCircularProgress {
                                size: resourceUsageMeter.implicitWidth
                                Layout.alignment: Qt.AlignHCenter
                                value: ResourceUsage.memoryUsedCache / ResourceUsage.memoryTotal
                                colPrimary: "#ffafaf"
                                colSecondary: "#080812"
                                lineWidth: 3
                                ClippedFilledCircularProgress {
                                    size: resourceUsageMeter.implicitWidth
                                    Layout.alignment: Qt.AlignHCenter
                                    value: ResourceUsage.memoryUsed / ResourceUsage.memoryTotal
                                    colPrimary: "#dfdfff"
                                    colSecondary: "transparent"
                                    lineWidth: 3
                                    Item {
                                        anchors.fill: parent
                                        MaterialIcon {
                                            anchors.centerIn: parent
                                            fill: 0
                                            icon: "memory_alt"
                                            font.pixelSize: 22
                                            color: "#DFDFFF"
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Rectangle { //swap progressbar
                        Layout.fillHeight:true
                        implicitWidth:15
                        color:"#12131F"
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
                        spacing:-2
                        Text{
                            text: `CPU USAGE:`
                            font.pixelSize:8
                            color: "#DFDFFF"
                        }
                        Text {
                            text: `${Math.floor(ResourceUsage.cpuUsage * 100)}%`
                            color: "#DFDFFF"
                            font.bold:true
                        }
                        Text{
                            text: `RAM USAGE:`
                            font.pixelSize:8
                            color: "#DFDFFF"
                        }
                        Text {
                            text: `${Math.floor(ResourceUsage.memoryUsed / ResourceUsage.memoryTotal * 100)}%`
                            color: "#DFDFFF"
                            font.bold:true
                        }
                        Text{
                            text: `RAM CACHE:`
                            font.pixelSize:8
                            color: "#DFDFFF"
                        }
                        Text {
                            text: `${Math.floor((ResourceUsage.memoryUsedCache - ResourceUsage.memoryUsed) / ResourceUsage.memoryTotal * 100)}%`
                            color: "#DFDFFF"
                            font.bold:true
                        }
                        Text{
                            text: `SWAP USAGE:`
                            font.pixelSize:8
                            color: "#DFDFFF"
                        }
                        Text {
                            text: `${Math.floor(ResourceUsage.swapUsedPercentage * 100)}%`
                            color: "#DFDFFF"
                            font.bold:true
                        }
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: root.hoverPopup 
                acceptedButtons: Qt.NoButton
                onEntered: {
                    root.popup = true; 
                    root.animPopup = true;
                    hideTimer.stop();
                    animTimer.stop();
                }
                onExited: hideTimer.restart(), animTimer.restart(), root.hoverPopup = false
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            root.hoverPopup = true
            root.popup = true; 
            root.animPopup = true;
            hideTimer.stop();
            animTimer.stop();
        }
        onExited: hideTimer.restart(), animTimer.restart()
    }
}
