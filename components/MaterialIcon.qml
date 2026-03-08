// a thin wrapper for Material Symbols
import QtQuick

Text {
  id: root
  property real fill: 0
  property int grad: 0
  required property string icon

  font.family: "Material Symbols Rounded"
  font.hintingPreference: Font.PreferFullHinting
  // see https://m3.material.io/styles/typography/editorial-treatments#e9bac36c-e322-415f-a182-264a2f2b70f0
  font.variableAxes: {
    "FILL": root.fill,
    "opsz": root.fontInfo.pixelSize,
    "GRAD": root.grad,
    "wght": root.fontInfo.weight
  }
  renderType: Text.NativeRendering
  text: root.icon
}
