import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.services
import qs.config

Loader {
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    sourceComponent: Config.barOrientation ? horizontal : vertical
    asynchronous: true

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
                    text: Time.format("dd/MM")
                    color: Color.secondary
                    font.pixelSize: 8
                    font.bold: false
                }
            }
        }
    }
    Component {
        id: horizontal
        ColumnLayout {
            spacing:-3
            implicitHeight:Config.barWidth
            Text {
                text: Time.format("hh:mm")
                Layout.alignment: Qt.AlignRight
                color: Color.secondary
                font.pixelSize: 12
                font.bold: true
                font.family: "monospace"
            }
            Text {
                text: Time.format("dd/MM/yyyy")
                Layout.alignment: Qt.AlignHCenter
                color: Color.secondary
                opacity:0.8
                font.pixelSize: 8
                font.bold: true
                font.family: "monospace"
            }
        }
    }
}
