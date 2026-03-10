pragma Singleton

pragma ComponentBehavior: Bound

import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

/**
 * A service that provides easy access to the active Mpris player, code from caelestia long time ago idk i forgor
 */
Singleton {
	id: root;
    property bool lock: false
	property MprisPlayer trackedPlayer: null;
	property MprisPlayer activePlayer: trackedPlayer ?? Mpris.players.values[0] ?? null;
	property var allPlayer: Mpris.players;
	signal trackChanged(reverse: bool);
    property real visualPosition: 0

    Timer {
        id: postimer
        running: root.activePlayer?.playbackState == MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: { 
            activePlayer.positionChanged();
            playerPosition.running = true
            //console.log(root.activePlayer.position, root.visualPosition)
        }
    }
    Process {
        id: playerPosition

        // dbus-send + parse int64 Position
        command: [
            "bash", "-c",
            "dbus-send --print-reply --dest=" + root.activePlayer.dbusName +
            " /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get " +
            "string:org.mpris.MediaPlayer2.Player string:Position " +
            " | awk '/int64/ {print $NF}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                var ns = parseFloat(this.text)     // nanoseconds
                if (!ns) return

                var val = ns / 1000000        // seconds

                if (activePlayer.canSeek && activePlayer.positionSupported) {
                    root.visualPosition = val
                }
                //console.log(val)
            }
        }
    }    
    Connections {
        target: root.activePlayer
        onPostTrackChanged: {
            root.visualPosition = 0
        }
    }

	property bool __reverse: false;

    property var activeTrack;

    function autoSelectPlayer() {
        if (lock) return

        for (const p of Mpris.players.values) {
            if (p.isPlaying) {
                trackedPlayer = p
                return
            }
        }

        if (Mpris.players.values.length > 0)
        trackedPlayer = Mpris.players.values[0]
    }
    function setActivePlayer(player: MprisPlayer) {
        lock = true
        trackedPlayer = player
    }
    function resetAutoPlayer() {
        lock = false
        autoSelectPlayer()
    }

    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData

            Component.onCompleted: {
                if (!root.lock && root.trackedPlayer === null && modelData.isPlaying)
                root.trackedPlayer = modelData
            }

            Component.onDestruction: {
                if (!root.lock && root.trackedPlayer === modelData)
                root.autoSelectPlayer()
            }

            function onPlaybackStateChanged() {
                if (!root.lock && modelData.isPlaying)
                root.trackedPlayer = modelData
            }
        }
    }

	Connections {
		target: activePlayer

		function onPostTrackChanged() {
			root.updateTrack();
		}

		function onTrackArtUrlChanged() {
			// console.log("arturl:", activePlayer.trackArtUrl)
			// root.updateTrack();
			if (root.activePlayer.uniqueId == root.activeTrack.uniqueId && root.activePlayer.trackArtUrl != root.activeTrack.artUrl) {
				// cantata likes to send cover updates *BEFORE* updating the track info.
				// as such, art url changes shouldn't be able to break the reverse animation
				const r = root.__reverse;
				root.updateTrack();
				root.__reverse = r;

			}
		}
	}
	onActivePlayerChanged: this.updateTrack();

	function updateTrack() {
		//console.log(`update: ${this.activePlayer?.trackTitle ?? ""} : ${this.activePlayer?.trackArtists}`)
		this.activeTrack = {
			uniqueId: this.activePlayer?.uniqueId ?? 0,
			artUrl: this.activePlayer?.trackArtUrl ?? "",
			title: this.activePlayer?.trackTitle || Translation.tr("Unknown Title"),
			artist: this.activePlayer?.trackArtist || Translation.tr("Unknown Artist"),
			album: this.activePlayer?.trackAlbum || Translation.tr("Unknown Album"),
		};

		this.trackChanged(__reverse);
		this.__reverse = false;
	}

	property bool isPlaying: this.activePlayer && this.activePlayer.isPlaying;
	property bool canTogglePlaying: this.activePlayer?.canTogglePlaying ?? false;
	function togglePlaying() {
		if (this.canTogglePlaying) this.activePlayer.togglePlaying();
	}

	property bool canGoPrevious: this.activePlayer?.canGoPrevious ?? false;
	function previous() {
		if (this.canGoPrevious) {
			this.__reverse = true;
			this.activePlayer.previous();
		}
	}

	property bool canGoNext: this.activePlayer?.canGoNext ?? false;
	function next() {
		if (this.canGoNext) {
			this.__reverse = false;
			this.activePlayer.next();
		}
	}

	property bool canChangeVolume: this.activePlayer && this.activePlayer.volumeSupported && this.activePlayer.canControl;

	property bool loopSupported: this.activePlayer && this.activePlayer.loopSupported && this.activePlayer.canControl;
	property var loopState: this.activePlayer?.loopState ?? MprisLoopState.None;
	function setLoopState(loopState: var) {
		if (this.loopSupported) {
			this.activePlayer.loopState = loopState;
		}
	}

	property bool shuffleSupported: this.activePlayer && this.activePlayer.shuffleSupported && this.activePlayer.canControl;
	property bool hasShuffle: this.activePlayer?.shuffle ?? false;
	function setShuffle(shuffle: bool) {
		if (this.shuffleSupported) {
			this.activePlayer.shuffle = shuffle;
		}
	}

	IpcHandler {
		target: "mpris"

		function pauseAll(): void {
			for (const player of Mpris.players.values) {
				if (player.canPause) player.pause();
			}
		}

		function playPause(): void { root.togglePlaying(); }
		function previous(): void { root.previous(); }
		function next(): void { root.next(); }
	}
}

