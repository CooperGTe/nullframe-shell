import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./"
import qs.config

Rectangle {
    id:root
    property bool extend: false

    Layout.fillHeight:true 
    Layout.fillWidth:true
    implicitHeight:root.extend ? 70 : 25
    Behavior on implicitHeight {
        NumberAnimation { duration: 400; easing.type: Easing.InOutCirc }
    }
    color:Color.container
    radius:15
    ColumnLayout {
        anchors.fill:parent
        Item {
            Layout.fillWidth:true
            implicitHeight:25
            RowLayout {
                anchors.fill:parent
                anchors.margins:5
                Button {
                    Layout.alignment:Qt.AlignBottom
                    implicitHeight:25
                    implicitWidth:125
                    background: Rectangle {
                        radius:20
                        color: stack.currentItem.objectName === "cal" ? Color.surface : Color.container_high
                    }
                    Text {
                        color: stack.currentItem.objectName === "cal" ? Color.base: Color.surface
                        text:"Calendar"
                        anchors.centerIn:parent
                        font.bold:true
                    }
                    onClicked: {
                        if (stack.currentItem.objectName === "nc") stack.replace(cal)
                        stack.forward = true
                    }
                }
                Button {
                    Layout.alignment:Qt.AlignBottom
                    implicitHeight:25
                    implicitWidth:125
                    background: Rectangle {
                        radius:20
                        color: stack.currentItem.objectName === "nc" ? Color.surface : Color.container_high
                    }
                    Text {
                        color:stack.currentItem.objectName === "nc" ? Color.base : Color.surface
                        text:"Notification Center"
                        anchors.centerIn:parent
                        font.bold:true
                    }
                    onClicked:{
                        if (stack.currentItem.objectName === "cal") stack.replace(nc)
                        stack.forward = false
                    }
                }
                Item {
                    Layout.fillWidth:true
                }
                Button {
                    Layout.alignment:Qt.AlignBottom
                    implicitHeight:25
                    implicitWidth:25
                    background: Rectangle {
                        radius:20
                        color: Color.container_high
                    }
                    Text {
                        color:Color.surface
                        text:"^"
                        anchors.centerIn:parent
                        font.bold:true
                    }
                    onClicked: root.extend = !root.extend
                }
            }
        }
        StackView {
            id: stack
            initialItem: cal
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip:true
            property bool forward: true

            replaceEnter: Transition {
                NumberAnimation {
                    property: "x"
                    from: stack.forward ? stack.width : -stack.width
                    to: 0
                    easing.type: Easing.OutQuart
                    duration: 600
                }
            }

            replaceExit: Transition {
                NumberAnimation {
                    property: "x"
                    from: 0
                    to: stack.forward ? -stack.width : stack.width
                    easing.type: Easing.OutQuart
                    duration: 600
                }
            }
        }
        Component {
            id: cal
            ColumnLayout {
                objectName: "cal"
                clip:true
                Rectangle {
                    Layout.bottomMargin:-5
                    Layout.margins:5
                    Layout.fillHeight:true
                    Layout.fillWidth:true
                    color:Color.container_high
                    radius:15
                }
                Date{
                    anchors.bottom:parent.bottom
                }
            }
        }
        Component {
            id: nc
            Text {
                objectName: "nc"
                text:"asd"
            }
        }
    }
}
