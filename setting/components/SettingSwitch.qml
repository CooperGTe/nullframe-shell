import QtQuick

import qs.components

Column {
    id: root

    required property string mainText
    property string subText

    anchors.margins: 10
    StyledText {
        text: root.mainText
        surface: 0
    }
    StyledText {
        text: root.subText
        surface: 2
    }
}
