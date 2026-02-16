import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config

Loader {
    Layout.alignment: Qt.AlignBottom && Qt.AlignHCenter
    sourceComponent: Config.barOrientation ? horizontal : vertical
    Component {
        id: vertical
        ColumnLayout {
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
                Layout.alignment: Qt.AlignHCenter
                Text {
                    text: Time.format("dd:MM")
                    color: Color.secondary
                    font.pixelSize: 8
                    font.bold: false
                }
            }
        }
    }
    Component {
        id: horizontal
        RowLayout {
            Layout.alignment: Qt.AlignBottom && Qt.AlignHCenter
            Layout.fillWidth:true
            spacing:0
            implicitHeight:50
            Text {
                text: Time.format("hh:mm")
                Layout.alignment: Qt.AlignHCenter
                color: Color.secondary
                font.pixelSize: 18
                font.bold: true
                font.family: "monospace"
            }
        }
    }
}
