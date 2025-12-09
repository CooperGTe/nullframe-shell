import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
	// This stores all the information shared between the lock surfaces on each screen.
    IpcHandler {
        target: "lockscreen"
        function lock() {
			if (lock.locked) 
				return;
            delay.start()
        }
    }
    Timer {
        id:delay
        interval: 400
        running: false
        repeat:false
        onTriggered: lock.locked = true
    }
	LockContext {
		id: lockContext

        property Timer delayedUnlock: Timer {
			interval: 1000
			repeat: false
			onTriggered: lock.locked = false
		}

		onUnlocked: {
			delayedUnlock.start();
		}
	}

	WlSessionLock {
        id: lock

        LockSurface {
            context: lockContext
        }
	}
}
