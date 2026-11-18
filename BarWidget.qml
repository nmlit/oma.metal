import QtQuick
import qs.Commons
import qs.Ui

BarWidget {
  id: root

  readonly property string pluginId: "oma.metal"
  moduleName: pluginId

  readonly property var metal: bar && bar.shell ? bar.shell.serviceFor(pluginId) : null
  readonly property bool playing: metal ? metal.playing : false

  visible: metal !== null
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    slotSize: Style.bar.iconSlot
    tooltipText: root.playing ? "Stoppa metal" : "Spela metal"
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
