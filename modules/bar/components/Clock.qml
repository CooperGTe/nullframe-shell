import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.services

ColumnLayout {
    Layout.alignment: Qt.AlignBottom && Qt.AlignHCenter
    Layout.fillWidth:true
    spacing:0
    implicitHeight:50
    Text {
        text: Time.format("hh")
        Layout.alignment: Qt.AlignHCenter
        color: "#DFDFFF"
        font.pixelSize: 18
        font.bold: true
        font.family: "monospace"
    }
    Text {
        text: Time.format("mm")
        Layout.alignment: Qt.AlignHCenter
        font.family: "monospace"
        color: "#DFDFFF"
        font.pixelSize: 18
        font.bold: true
    }
    Row {
        Text {
            text: Time.format("dd:MM")
            color: "#DFDFFF"
            font.pixelSize: 8
            font.bold: false
        }
    }
}

