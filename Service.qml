import QtQuick
import Quickshell.Io

// Delat tillstånd för alla skärmar. Sanningen är systemd-enheten oma-metal,
// så ikonen synkas även efter omarchy-restart-shell medan strömmen spelar.
Item {
  id: root

  property var shell: null

  readonly property string pluginId: "oma.metal"
  readonly property string script: Qt.resolvedUrl("metal.sh").toString().replace("file://", "")

  property bool playing: false
  readonly property bool busy: ctlProc.running

  function run(action) {
    if (ctlProc.running) return
    ctlProc.command = ["bash", root.script, action]
    ctlProc.running = true
  }

  function toggle() { if (ctlProc.running) return; var next = !root.playing; run(next ? "start" : "stop"); root.playing = next }
  function play() { if (ctlProc.running) return; run("start"); root.playing = true }
  function stop() { if (ctlProc.running) return; run("stop"); root.playing = false }
  function refresh() { if (!statusProc.running && !ctlProc.running) statusProc.running = true }

  Process {
    id: ctlProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.playing = text.trim() === "playing"
    }
    onExited: function(code) { if (code !== 0) Qt.callLater(root.refresh) }
  }

  Process {
    id: statusProc
    command: ["bash", root.script, "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.playing = text.trim() === "playing"
    }
  }

  // Fångar även att strömmen dött av sig själv (t.ex. nätverksfel).
  Timer {
    interval: 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  // omarchy-shell -q oma.metal toggle | play | stop
  IpcHandler {
    target: root.pluginId
    function toggle(): void { root.toggle() }
    function play(): void { root.play() }
    function stop(): void { root.stop() }
  }
}
