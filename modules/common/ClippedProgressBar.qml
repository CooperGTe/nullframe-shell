import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

ProgressBar {
    id: root
    property bool vertical: true
    property real valueBarWidth: 20
    property real valueBarHeight: 36
    property color highlightColor: "#685496"
    property color trackColor: Qt.rgba(
        Qt.colorEqual(highlightColor, "transparent") ? 0 : Qt.colorEqual(highlightColor, "#000000") ? 0 : 104/255,
        84/255,
        150/255,
        0.5
    )
    property alias radius: contentItem.radius
    property string text

    // Simple inline text item
    default property Item textMask: Item {
        width: valueBarWidth
        height: valueBarHeight
        Text {
            anchors.centerIn: parent
            font: root.font
            text: root.text
            color: "white"
        }
    }

    text: Math.round(value * 100)
    font {
        pixelSize: 13
        weight: text.length > 2 ? Font.Medium : Font.DemiBold
    }

    background: Item {
        implicitHeight: valueBarHeight
        implicitWidth: valueBarWidth
    }

    contentItem: Rectangle {
        id: contentItem
        anchors.fill: parent
        radius: 9999
        color: root.trackColor
        visible: false

        Rectangle {
            id: progressFill
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
            }
            width: parent.width * root.visualPosition
            height: parent.height
            radius: 9
            color: root.highlightColor

            states: State {
                name: "vertical"
                when: root.vertical
                AnchorChanges {
                    target: progressFill
                    anchors {
                        top: undefined
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                }
                PropertyChanges {
                    target: progressFill
                    width: parent.width
                    height: parent.height * root.visualPosition
                }
            }
        }
    }

    OpacityMask {
        id: roundingMask
        visible: false
        anchors.fill: parent
        source: contentItem
        maskSource: Rectangle {
            width: contentItem.width
            height: contentItem.height
            radius: contentItem.radius
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: roundingMask
        invert: true
        maskSource: root.textMask
    }
}
