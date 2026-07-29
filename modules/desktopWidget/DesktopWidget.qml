pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.Mpris

import qs.services
import qs.components
import qs.config

Variants {
    model: Quickshell.screens

    Scope {
        id: root

        readonly property MprisPlayer activePlayer: MprisController.activePlayer
        readonly property real position: MprisController.visualPosition
        required property var modelData
        
        LazyLoader {
            active: Compositor.hasTiling ? false : true

            PanelWindow {
                id:wgRoot

                // Layer props
                screen: root.modelData
                exclusionMode: ExclusionMode.Normal
                WlrLayershell.layer: WlrLayer.Bottom

                color: "transparent"

                anchors {
                    bottom: true
                    right: true
                }

                implicitWidth:content.implicitWidth + 30
                implicitHeight:content.implicitHeight + 30

                ColumnLayout {
                    id:content
                    spacing:0
                    Item {
                        implicitWidth: clock.implicitWidth
                        implicitHeight: clock.implicitHeight
                        Layout.alignment: Qt.AlignRight
                        MouseArea {
                            anchors.fill:parent
                            onClicked: Config.desktopWidget.invertClockColor = !Config.desktopWidget.invertClockColor
                        }
                        ColumnLayout {
                            id:clock
                            anchors.fill:parent
                            Text {
                                text: Time.format("hh:mm")
                                Layout.alignment: Qt.AlignRight
                                color: Config.desktopWidget.invertClockColor ? Color.base : Color.secondary
                                font.pixelSize: 50
                                font.bold:true
                                font.family: "monospace"
                                style: Text.Raised
                                styleColor: !Config.desktopWidget.invertClockColor ? Color.base : Color.primary
                            }
                            Text {
                                text: Time.format("yyyy年MM月dd日")
                                Layout.alignment: Qt.AlignRight
                                Layout.topMargin: -10
                                color: Config.desktopWidget.invertClockColor ? Color.base : Color.secondary
                                font.pixelSize: 15
                                font.bold: false
                                style: Text.Raised
                                styleColor: !Config.desktopWidget.invertClockColor ? Color.base : Color.primary
                            }
                        }
                    }
                    Rectangle {
                        visible: Config.desktopWidget.media
                        Layout.alignment: Qt.AlignRight
                        Layout.topMargin: 10
                        color: Color.base
                        implicitHeight: 70
                        implicitWidth: 230
                        radius:50
                        RowLayout {
                            anchors.fill: parent
                            ClippingRectangle {
                                implicitWidth:60
                                implicitHeight:60
                                Layout.leftMargin:5
                                radius:60
                                clip: true
                                color: Color.container
                                Image {
                                    anchors.fill: parent
                                    source: root.activePlayer?.trackArtUrl ?? ""
                                    fillMode: Image.PreserveAspectCrop
                                    cache: true
                                }
                            }
                            ColumnLayout{
                                Layout.rightMargin:25
                                Text{
                                    Layout.alignment:Qt.AlignBottom
                                    text:root.activePlayer.trackTitle ?? ""
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 140
                                    font.pixelSize: 12
                                    color:Color.on_surface
                                    font.bold:true
                                }
                                Text{
                                    Layout.alignment:Qt.AlignTop
                                    text:root.activePlayer.trackArtist ?? ""
                                    Layout.maximumWidth: 140
                                    Layout.topMargin: -5
                                    font.pixelSize: 8
                                    color:Color.outline
                                }
                                Rectangle {
                                    // Stretches to fill all left-over space
                                    Layout.fillWidth: true
                                    Layout.alignment:Qt.AlignVCenter

                                    implicitHeight: 10
                                    radius: 20
                                    color: "transparent"

                                    Rectangle {
                                        anchors {
                                            bottom: parent.bottom
                                            top: parent.top
                                            left: parent.left
                                        }
                                        color: Color.primary

                                        implicitWidth: parent.width * (root.position / activePlayer.length)
                                        radius: parent.radius
                                    }
                                    Rectangle {
                                        anchors {
                                            top: parent.top
                                            bottom: parent.bottom
                                            right: parent.right
                                        }
                                        color: Color.container_high

                                        implicitWidth: parent.width * (1 - (root.position / activePlayer.length)) - 3
                                        radius: parent.radius
                                    }
                                    Rectangle {
                                        anchors {
                                            right: parent.right
                                            margins: 2.5
                                            verticalCenter:parent.verticalCenter
                                        }
                                        color: Color.primary

                                        implicitWidth: 5
                                        implicitHeight: 5
                                        radius: parent.radius
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        LazyLoader {
            //active: Hyprland.hasTiling ? false : true
            active: false

            PanelWindow {
                id:calroot
                // Layer props
                screen: root.modelData
                exclusionMode: ExclusionMode.Normal
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "widget"
                color: "transparent"

                anchors {
                    top: true
                    left: true
                }
                margins {
                    top: 30
                    left: 30
                }
                implicitWidth:160
                implicitHeight: 160
                Rectangle {
                    anchors.fill: parent
                    //color: "transparent"
                    color: Color.base
                    /*color: Qt.rgba(Qt.color(Color.base).r,
                    Qt.color(Color.base).g,
                    Qt.color(Color.base).b,
                    0.5)*/
                    radius: 10
                    /*border{
                        width: 1
                        color: Qt.rgba(Qt.color(Color.container_high).r,
                        Qt.color(Color.container_high).g,
                        Qt.color(Color.container_high).b,
                        0.4)
                    }*/
                    ColumnLayout {
                        id: monthColumn
                        anchors.fill: parent
                        anchors.margins: 10

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
                                    color: Color.secondary
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

                                delegate: Item {
                                    id: dayItem

                                    required property var model
                                    property bool overrideDate: model.date === grid.todayOverride


                                    Rectangle {
                                        id: todayPanel

                                        anchors.centerIn:parent
                                        width: parent.width
                                        height: parent.width

                                        color: model.today 
                                            ? Color.primary 
                                            : (hover.hovered ? Color.surface_container_high : "transparent")
                                        radius: 12
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
                                            return Color.tertiary
                                            return Color.secondary
                                        }
                                        opacity: dayItem.model.today || dayItem.model.month === grid.month ? 1 : 0.3
                                        font.pixelSize: 12
                                        font.weight: Font.Light
                                        // font.bold: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        LazyLoader {
            //active: Hyprland.hasTiling ? false : true
            active: false

            PanelWindow {
                id:clockroot
                // Layer props
                screen: root.modelData
                exclusionMode: ExclusionMode.Normal
                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "widget"
                color: "transparent"

                anchors {
                    top: true
                    left: true
                }
                margins {
                    top: 30
                    left: 30+10+160
                }
                implicitWidth:160
                implicitHeight: 160
                Rectangle {
                    anchors.fill: parent
                    //color: "transparent"
                    color: Qt.rgba(Qt.color(Color.base).r,
                    Qt.color(Color.base).g,
                    Qt.color(Color.base).b,
                    0.5)
                    radius: 10
                    border{
                        width: 1
                        color: Qt.rgba(Qt.color(Color.container_high).r,
                        Qt.color(Color.container_high).g,
                        Qt.color(Color.container_high).b,
                        0.4) 
                    }
                    ColumnLayout {
                        anchors.fill:parent
                        anchors.margins: 10
                        spacing: 0
                        RowLayout {
                            Layout.fillWidth: true

                            StyledText {
                                text: "Jakarta"
                                font.pixelSize: 14
                                Layout.fillWidth: true
                            }
                            Rectangle  {
                                color: Qt.rgba(Qt.color(Color.container_high).r,
                                Qt.color(Color.container_high).g,
                                Qt.color(Color.container_high).b,
                                0.4) 
                                radius: 20
                                implicitHeight: 20
                                implicitWidth: 50

                                StyledText {
                                    anchors.centerIn: parent
                                    text: "Refresh"
                                    surface: 2
                                    font.pixelSize: 10
                                }
                            }
                        }
                        RowLayout {
                            Text {
                                text: "256"+"°"
                                font.bold:true
                                font.pixelSize: 30
                                color: Color.secondary
                            }
                            MaterialIcon {
                                icon: "partly_cloudy_day"
                                font.pixelSize: 40
                                color: Color.secondary
                            }
                        }
                        StyledText {
                            text: "Partially Cloudy"
                            surface: 2
                        }
                        RowLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            StyledText {
                                text: "Feel-like:"
                                surface: 2
                                font.pixelSize: 10
                                Layout.fillWidth: true
                            }
                            StyledText {
                                text: "HELL"+"°"
                                surface: 2
                                font.pixelSize: 10
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: "Humidity:"
                                surface: 2
                                font.pixelSize: 10
                                Layout.fillWidth: true
                            }
                            StyledText {
                                text: "-130%"
                                surface: 2
                                font.pixelSize: 10
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            StyledText {
                                text: "Wind Speed:"
                                surface: 2
                                font.pixelSize: 10
                                Layout.fillWidth: true
                            }
                            StyledText {
                                text: "64 km/s"
                                surface: 2
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }
        }
    }
}
