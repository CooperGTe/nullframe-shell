// Shared Variable/State that work with multimonitor
// how this work? no idea, claude say this work and it work(jk)
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property var states: ({})

    readonly property Component stateComponent: Component {
        Variable {}
    }

    function ensure(name) {
        if (!states[name]) {
            states[name] = stateComponent.createObject(root)
        }
        return states[name]
    }

    function get(name) {
        return ensure(name)
    }
}
