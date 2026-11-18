import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root

  readonly property string pluginId: "oma.metal"
  moduleName: pluginId

  readonly property var metal: bar && bar.shell ? bar.shell.serviceFor(pluginId) : null
  readonly property bool playing: metal ? metal.playing : false
  readonly property string tooltip: !playing ? "oma.metal – klicka för att spela"
    : (metal.nowPlaying !== "" ? metal.nowPlaying : "Bandit Metal – hämtar låt…")

  visible: metal !== null
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: Style.bar.iconSlot
    tooltipText: root.tooltip
    // Baren läser texten när pekaren kommer in; visa ny låt direkt om den byts
    // medan man hovrar.
    onTooltipTextChanged: if (tooltipHovered && root.bar) root.bar.showTooltip(button, tooltipText)
    onTooltipHoveredChanged: if (root.metal) root.metal.hovered = tooltipHovered
    iconComponent: Component {
      Image {
        source: Qt.resolvedUrl(root.playing ? "icon-red.png" : "icon-white.png")
        width: Style.bar.iconCanvas
        height: Style.bar.iconCanvas
        sourceSize.width: Style.bar.iconCanvas * 3
        sourceSize.height: Style.bar.iconCanvas * 3
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
      }
    }
    onPressed: function(b) {
      if (b === Qt.LeftButton && root.metal) root.metal.toggle()
    }
  }
}
