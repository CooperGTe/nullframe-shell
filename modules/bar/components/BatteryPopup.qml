import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services
import qs.modules.common

PopupWindow {
    id:root
    readonly property var chargeState: Battery.chargeState
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property real timeToEmpty:Battery.timeToEmpty
    readonly property real timeToFull:Battery.timeToFull
    readonly property real energyRate:Battery.energyRate
    readonly property real healthPercentage:Battery.healthPercentage
    readonly property bool isLow: percentage <= 15 / 100
    property var parent
    property bool visibility: parent.popupVisibility
    onVisibilityChanged:console.log(root.visibility)
    Behavior on visibility {
        SequentialAnimation {
            ScriptAction { 
                script: root.visible = true
            }
            PauseAnimation { 
                duration: 400
            }
            ScriptAction { 
                script: if (!visibility) root.visible = false
            }
        }
    }
    anchor.item: parent
    anchor.edges: Edges.Left
    anchor.gravity: Edges.Right
    anchor.margins{
        left: 40
        right: 0

    }
    implicitWidth: 200
    implicitHeight: 100


    visible: false
    color:"transparent"
    function formatTime(sec) {
        var sec_num = parseInt(sec, 10); // don't forget the second param
        var hours   = Math.floor(sec_num / 3600);
        var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        var seconds = sec_num - (hours * 3600) - (minutes * 60);

        if (hours === 0) {
            hours   = "";
        } else if (hours   < 10) {
            hours   = "0"+hours+":";
        } else hours+":"
        if (minutes < 10) {minutes = "0"+minutes;}
        if (seconds < 10) {seconds = "0"+seconds;}
        return `${hours}${minutes}:${seconds}`
    }
    ItemShadow{}
    Rectangle {
        anchors {
            fill:parent
            rightMargin: root.visibility ? 20 : 300
            leftMargin: root.visibility ? 5 : -310
            margins:20
        }
        Behavior on anchors.leftMargin {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        Behavior on anchors.rightMargin {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }
        color: Color.base
        radius:20
        ColumnLayout {
            spacing:0
            anchors.margins:10
            anchors.fill:parent
            Text {
                text: "Battery: " + root.percentage * 100 + "%"
                color: Color.surface
                font.bold:true
            }
            Text {
                text: "Est: " + (root.isCharging ? root.formatTime(root.timeToFull) : root.formatTime(root.timeToEmpty))
                color: Color.secondary
            }
        }
    }
}
