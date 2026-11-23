import QtQuick
import qs.config

Rectangle {
  id: root
  property string glyph: ""
  property bool active: false
  property bool emphasized: false
  property bool disabledButton: false
  property color accentColor: Theme.primary
  signal clicked()

  width: 36
  height: 34
  radius: 11
  opacity: root.disabledButton ? 0.32 : 1
  color: root.active ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.16)
    : area.containsMouse && !root.disabledButton ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.09)
    : "transparent"
  border.width: 1
  border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, root.active ? 0.38 : root.emphasized ? 0.24 : 0.12)

  Text {
    anchors.centerIn: parent
    text: root.glyph
    color: root.active || root.emphasized ? root.accentColor : Theme.textDim
    opacity: root.active || root.emphasized ? 1 : 0.78
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
  }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (!root.disabledButton) root.clicked();
    }
  }
}
