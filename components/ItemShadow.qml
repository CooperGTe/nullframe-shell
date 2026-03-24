pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects

Item {
    id: root
    property real size: 1
    property real spread: 1.5
    property real range: 16
    property real transparency: 0.5
    property bool enabled: true

    Component.onCompleted: {
        parent.layer.enabled = true;
        parent.layer.effect = effectComponent;
    }
    function update() {
        parent.layer.effect = null;
        parent.layer.effect = effectComponent;
    }

    Component {
        id: effectComponent
        MultiEffect {
            shadowEnabled: root.enabled
            shadowOpacity: root.transparency
            shadowColor: "black"
            shadowBlur: root.spread
            shadowScale: root.size
            blurMax: root.range
        }
    }
}
