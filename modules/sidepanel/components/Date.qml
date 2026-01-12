import QtQuick    
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common
import qs.services
import qs.config

Rectangle {
    id:root
    property int currentMonth: Number(Time.format("MM")) - 1
    property int currentYear:  Number(Time.format("yyyy"))
    Layout.fillWidth:true
    color: Color.container
    radius:10
    implicitHeight:180
    implicitWidth:300
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
                        color: Color.surface
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

                            color: model.today ? Color.surface : "transparent"
                            border.width: model.today ? 0 : 2
                            // border.color: hover.hovered ? Theme.colors.bg_light : "transparent"
                            border.color: {
                                if (hover.hovered) return Color.container_high
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
                                if (model.today) return Color.base

                                const dayOfWeek = dayItem.model.date.getUTCDay()
                                if (dayOfWeek === 5 || dayOfWeek === 6)
                                return Color.error
                                return Color.surface
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
                    border.color: Color.surface

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
        }
        ColumnLayout {
            Layout.fillHeight: true
            spacing:0
            Text {
                text: Time.format("MMM. d")
                font.bold:true
                font.pointSize:30
                Layout.alignment:Qt.AlignRight
                color: Color.surface
            }
            Text {
                text:Time.format("dddd")
                font.bold:true
                color: Color.surface
                Layout.alignment:Qt.AlignRight
            }
            //moonclock
            Item {
                implicitWidth: 30
                implicitHeight: 30
                Layout.alignment:Qt.AlignRight
                Layout.topMargin: 10 
                Layout.bottomMargin: 30 

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Color.surface
                    clip: true

                    Rectangle {
                        width: parent.width
                        height: parent.height
                        radius: width / 2
                        color: Color.container
                        property real phase: Time.synodicDays / 29.53059
                        property real dir: phase < 0.5 ? -1 : 1

                        x: dir * width * (1 - Math.abs(1 - 2 * phase))               
                    }
                }
            }            
            RowLayout {
                id: monthSelector
                Layout.margins: 0
                Layout.fillWidth: true
                Layout.fillHeight: true

                Button {
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 10
                    implicitHeight: monthText.height
                    implicitWidth: implicitHeight
                    background: Rectangle {
                        color:  "transparent"
                        radius:5
                        border.width:2
                        border.color: Color.container_high
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
                        color: Color.surface
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
                        border.color: Color.container_high
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
                        color: Color.surface
                    }
                }

                Text {
                    id: monthText
                    Layout.alignment: Qt.AlignLeft
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignRight

                    text:root.currentYear + "年 " + Qt.locale("ja_JP").monthName(root.currentMonth)

                    font.pointSize: 10
                    color: Color.surface
                }
            }
        }
    }
}
