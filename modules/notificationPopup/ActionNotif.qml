pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    property var modelAction: []
    spacing:5
    Layout.fillWidth:true
    Repeater {
        model: modelAction
        Button {
            Layout.fillWidth: true
            implicitHeight: 30
            onClicked: modelData.invoke()
            text: modelData.label
            Component.onCompleted: console.log(JSON.stringify(modelData.label))
        }
    }
}

