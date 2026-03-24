pragma ComponentBehavior: Bound

import qs.config
import QtQuick
import QtQuick.Effects

Item {
    id:root

    required property bool hug

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: Color.base

        layer.enabled: true
        layer.effect: MultiEffect {
            maskSource: mask
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }
    }

    Item {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.margins: 0
            anchors.leftMargin: Config.bar.position === 0 ? (root.hug 
            ? Config.barTotalWidth
            : 0 + this.anchors.margins)
            : this.anchors.margins

            anchors.topMargin: Config.bar.position === 1 ? (root.hug  
            ? Config.barTotalWidth
            : 0 + this.anchors.margins)
            : this.anchors.margins

            anchors.rightMargin:  Config.bar.position === 2 ? (root.hug
            ? Config.barTotalWidth
            : 0 + this.anchors.margins)
            : this.anchors.margins

            anchors.bottomMargin:  Config.bar.position === 3 ? (root.hug  
            ? Config.barTotalWidth
            : 0 + this.anchors.margins)
            : this.anchors.margins


            radius: root.hug ? 15 : 0

            component Anim: NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }

            Behavior on anchors.leftMargin { Anim {} }
            Behavior on anchors.topMargin { Anim {} }
            Behavior on anchors.rightMargin { Anim {} }
            Behavior on anchors.bottomMargin { Anim {} }
            Behavior on radius { Anim {} }
        }
    }
}
