import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell
import qs.services
import qs.modules.common

Rectangle {
    id:root

    color: "transparent"
    radius:30
    implicitHeight:100
    Layout.fillWidth: true

    function time(sec) {
        var h = Math.floor(sec / 3600);
        var m = Math.floor((sec % 3600) / 60);
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    RowLayout{
        anchors.fill:parent
        ClippingRectangle {
            implicitWidth:60
            implicitHeight:60
            Layout.alignment:Qt.AlignVCenter
            Layout.margins:10
            radius:60
            clip: true
            color: "#12131F"
            Image {
                anchors.fill: parent
                source: Quickshell.shellDir + "/assets/profile.png"
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 256
                sourceSize.height: 256
                asynchronous: true
                mipmap:true
                smooth:true
                cache: true
            }
        }
        ColumnLayout {
            Layout.alignment:Qt.AlignLeft
            spacing:0

            Text {
                Layout.alignment: Qt.AlignLeft
                text: Quickshell.env('USER')
                color: "#dfdfff"
                font.bold:true
                font.family:"monospace"
                font.pixelSize:16
                Layout.fillWidth:true
            }
            Text {
                Layout.alignment: Qt.AlignLeft
                text: System.prettyName
                color: "#dfdfff"
                font.pixelSize:10
            }
            Text {
                Layout.alignment: Qt.AlignLeft
                text: "Uptime: " + root.time(System.uptime)
                color: "#dfdfff"
                font.pixelSize:10
            }
        }
        RowLayout {
            Layout.alignment:Qt.AlignRight
            Rectangle {
                color: "#12131F"
                radius:10
                implicitWidth:32
                implicitHeight:32
                MaterialIcon {
                    icon: "settings"
                    anchors.centerIn:parent
                    font.pixelSize: 20
                    color: "#DFDFFF"
                }
            }
            Rectangle {
                color: "#12131F"
                radius:10
                implicitWidth:32
                implicitHeight:32
                MaterialIcon {
                    icon: "power_settings_new"
                    anchors.centerIn:parent
                    font.pixelSize: 20
                    color: "#DFDFFF"
                }
                MouseArea {
                    anchors.fill:parent
                    onClicked: console.log("teste")
                }
            }
        }
    }
}
