import QtQuick
import QtQuick.Layouts

import Quickshell

import qs.config
import qs.services
import qs.components

Rectangle {
    id: root

    property real timeProgress: ((Time.hours * 3600) + (Time.minutes * 60) + Time.seconds) / 86400

    implicitHeight: 80
    Layout.fillWidth: true

    color: Color.surface_container
    radius: 10

    Column {
        anchors.fill:parent
        anchors.margins: 5
        spacing:2
        Item {
            height:42
            width:parent.width
            anchors.left:parent.left

            StyledText {
                anchors.left:parent.left
                text: Time.format("hh:mm:ss")
                font.pixelSize:32
            }
            StyledText {
                anchors.right:parent.right
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize:22
                surface:2
                antialiasing: false
                text: {
                    if (Time.hours <= 5 ) return "おやすみなさい"
                    else if (Time.hours <= 10) return "おはよう！"
                    else if (Time.hours <= 18) return "こんにちわ!"
                    else if (Time.hours <= 20) return "こんばんわ!"
                    else return "おやすみなさい"
                }
                font.family: arkpixel.name
            }
            FontLoader {
                id: arkpixel
                source: `${Quickshell.shellDir}/assets/ark-pixel-12px-monospaced-ja.ttf`
            }
        }
        StyledProgressBar {
            value: root.timeProgress
            implicitWidth: parent.width
            color: Color.tertiary
        }
        StyledText {
            text: (Math.trunc(root.timeProgress * 10000) / 100).toFixed(2) + "% day has passed 〜"
            surface:3
        }
    }
}
