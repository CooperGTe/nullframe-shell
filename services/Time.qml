pragma Singleton

import Quickshell

Singleton {
    property alias enabled: clock.enabled
    readonly property date date: clock.date
    readonly property int hours: clock.hours
    readonly property int minutes: clock.minutes
    readonly property int seconds: clock.seconds

    function format(fmt: string): string {
        return Qt.formatDateTime(clock.date, fmt);
    }
    //volty45510 synodic clock
    readonly property real synodicDays: {
        const date = clock.date
        const synodicMonth = 29.53059
        const referenceNewMoon = new Date(Date.UTC(2000, 0, 6, 18, 14))

        const diffMs = date - referenceNewMoon
        const diffDays = diffMs / (1000 * 60 * 60 * 24)

        return ((diffDays % synodicMonth) + synodicMonth) % synodicMonth
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
