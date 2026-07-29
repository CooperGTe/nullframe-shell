import QtQuick
import QtQuick.Layouts

import qs.modules.panel.widgetpanel.components
import qs.config

ColumnLayout {
    id: root

    anchors {
        fill:parent
        margins: 5
        rightMargin: Config.widgetPanel.floating ? 5 : 0
    }

    Weather {}
    Clock {}
    Calendar {}
}
