import QtQuick
import QtQuick.Effects

Item {
    Component.onCompleted: {
        parent.layer.enabled = true;
        parent.layer.effect = effectComponent;
    }

    Component {
        id: effectComponent
        MultiEffect {
            shadowEnabled: true
            shadowOpacity: 1
            shadowColor: "black"
            shadowBlur: 1
            shadowScale: 1
        }
    }
}
