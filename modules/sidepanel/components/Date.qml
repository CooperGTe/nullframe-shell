import QtQuick    
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.services

Rectangle {
    id:root
    property int currentMonth: Number(Time.format("MM")) - 1
    property int currentYear:  Number(Time.format("yyyy"))
    Layout.fillWidth:true
    color: "#12131F"
    radius:20
    implicitHeight:220
    implicitWidth:230
    RowLayout {
        anchors.fill:parent
        anchors.margins:10

        ColumnLayout {
            id: monthColumn
            Layout.fillWidth: true
            Layout.fillHeight: true

            DayOfWeekRow {
                id: dayOfWeek
                Layout.fillWidth: true
                locale: Qt.locale("ja_JP")

                delegate: Item {
                    id: dayOfWeekItem
                    required property var model

                    implicitWidth: implicitHeight
                    implicitHeight: text1.implicitHeight

                    Text {
                        id: text1
                        text: model.narrowName
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        color: "#dfdfff"
                        font.pixelSize: 12
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: 100
                MonthGrid {
                    id: grid
                    anchors.fill: parent 

                    property date todayOverride: Time.date

                    month: root.currentMonth
                    year:  root.currentYear
                    locale: Qt.locale("en_US")

                    onClicked: date => todayOverride = date

                    delegate: Item {
                        id: dayItem

                        required property var model
                        property bool overrideDate: model.date === grid.todayOverride

                        width: 20
                        height: 20

                        Rectangle {
                            id: todayPanel
                            anchors.fill: parent

                            radius: 12

                            color: model.today ? "#dfdfff" : "transparent"
                            border.width: model.today ? 0 : 2
                            // border.color: hover.hovered ? Theme.colors.bg_light : "transparent"
                            border.color: {
                                if (hover.hovered) return "#22232F"
                                return "transparent"
                            }

                            HoverHandler {
                                id: hover
                            }
                        }

                        Text {
                            id: text
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: grid.locale.toString(dayItem.model.day)

                            color: {
                                if (model.today) return "#080812"

                                const dayOfWeek = dayItem.model.date.getUTCDay()
                                if (dayOfWeek === 5 || dayOfWeek === 6)
                                return "#ffafaf"
                                return "#dfdfff"
                            }
                            opacity: dayItem.model.today || dayItem.model.month === grid.month ? 1 : 0.3
                            font.pixelSize: 12
                            font.weight: Font.Light
                            // font.bold: true
                        }
                    }
                }
                Rectangle {
                    id: todayIndicator

                    readonly property Item todayInGrid: grid.contentItem.children.find(c => {
                        const d1 = c.model.date
                        const d2 = grid.todayOverride

                        return d1.getFullYear() === d2.getFullYear()
                        && d1.getMonth() === d2.getMonth()
                        && d1.getDate() === d2.getDate()
                    }) ?? null
                    property Item t: todayInGrid

                    // Component.onCompleted: {
                    //   console.log(grid.todayOverride)
                    //   console.log(t)
                    // }

                    // Connections {
                    //   target: grid
                    //   function onTodayOverrideChanged() {
                    //     // todayIndicator.t = grid.contentItem.children.find(c => +c.model.date === +grid.todayOverride) ?? null
                    //     // console.log(todayIndicator.t)
                    //     console.log(grid.todayOverride)
                    //   }
                    // }

                    x: t?.x ?? 0
                    y: t?.y ?? 0

                    width: t?.width ?? 0
                    height: t?.height ?? 0

                    radius: 10

                    color: "transparent"
                    border.width: 2
                    border.color: "#dfdfff"

                    Behavior on x {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Behavior on y {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
            RowLayout {
                id: monthSelector
                Layout.margins: 0
                Layout.fillWidth: true

                Button {
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 10
                    implicitHeight: monthText.height
                    implicitWidth: implicitHeight
                    background: Rectangle {
                        color:  "transparent"
                        radius:5
                        border.width:2
                        border.color: "#22232F"
                        anchors.fill:parent
                    }
                    onClicked: {
                        root.currentMonth--
                        if (root.currentMonth < 0) {
                            root.currentMonth = 11
                            root.currentYear--
                        }
                    }
                    MaterialIcon {
                        anchors.centerIn: parent
                        icon: "keyboard_arrow_left"
                        font.pixelSize: 24
                        color: "#dfdfff"
                    }
                }

                Button {
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 10
                    implicitHeight: monthText.height
                    implicitWidth: implicitHeight
                    background: Rectangle {
                        color:  "transparent"
                        radius:5
                        border.width:2
                        border.color: "#22232F"
                        anchors.fill:parent
                    }
                    onClicked: {
                        root.currentMonth++
                        if (root.currentMonth > 11) {
                            root.currentMonth = 0
                            root.currentYear++
                        }
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        icon: "keyboard_arrow_right"
                        font.pixelSize: 24
                        color: "#dfdfff"
                    }
                }

                Text {
                    id: monthText
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight

                    text:root.currentYear + "年 " + Qt.locale("ja_JP").monthName(root.currentMonth)

                    font.pointSize: 10
                    color: "#dfdfff"
                }
            }
        }
        ColumnLayout {
            Layout.fillHeight: true
            Layout.leftMargin:10
            spacing:10
            Rectangle {
                color: "#dfdfff"
                Layout.bottomMargin:-40
                radius:15
                implicitWidth:50
                implicitHeight:25
            }
            Button {
                implicitWidth:50
                implicitHeight:38
                background: Rectangle {
                    color: "transparent"
                }
                MaterialIcon {
                    icon: "calendar_today"
                    font.pixelSize: 18
                    anchors.horizontalCenter:parent.horizontalCenter
                    anchors.top:parent.top
                    fill:1
                    color: "#12131F"
                }
                Text {
                    text:"Calendar"
                    color: "#dfdfff"
                    font.bold: true
                    anchors.horizontalCenter:parent.horizontalCenter
                    anchors.bottom:parent.bottom
                }
            }
            Button {
                implicitWidth:50
                implicitHeight:38
                background: Rectangle {
                    color: "transparent"
                    radius:10
                }
                MaterialIcon {
                    icon: "timer"
                    font.pixelSize: 18
                    anchors.horizontalCenter:parent.horizontalCenter
                    anchors.top:parent.top
                    fill:0
                    color: "#dfdfff"
                }
                Text {
                    text:"Timer"
                    font.bold:true
                    color: "#dfdfff"
                    anchors.horizontalCenter:parent.horizontalCenter
                    anchors.bottom:parent.bottom
                }
            }
        }
    }
}
