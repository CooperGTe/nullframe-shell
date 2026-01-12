import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config

ColumnLayout {
    Layout.alignment: Qt.AlignBottom && Qt.AlignHCenter
    Layout.fillWidth:true
    spacing:0
    implicitHeight:50
    Text {
        text: Time.format("hh")
        Layout.alignment: Qt.AlignHCenter
        color: Color.secondary
        font.pixelSize: 18
        font.bold: true
        font.family: "monospace"
    }
    Text {
        text: Time.format("mm")
        Layout.alignment: Qt.AlignHCenter
        font.family: "monospace"
        color: Color.secondary
        font.pixelSize: 18
        font.bold: true
    }
    Row {
        Text {
            text: Time.format("dd:MM")
            color: Color.secondary
            font.pixelSize: 8
            font.bold: false
        }
    }
}

