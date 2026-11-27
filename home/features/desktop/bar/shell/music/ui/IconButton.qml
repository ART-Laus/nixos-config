import QtQuick
import qs.config
import qs.music

Rectangle {
  id: root
  property string glyph: ""
  property bool active: false
  property bool emphasized: false
  property bool disabledButton: false
  property color accentColor: MusicTheme.accent
  signal clicked()

  width: MusicTheme.buttonSize + 4
  height: MusicTheme.buttonSize
  radius: MusicTheme.radiusControl
  opacity: root.disabledButton ? 0.32 : 1
  color: root.active ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.16)
    : area.containsMouse && !root.disabledButton ? Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.09)
    : "transparent"
  border.width: 1
  border.color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, root.active ? 0.38 : root.emphasized ? 0.24 : 0.12)

  Text {
    anchors.centerIn: parent
    text: root.glyph
    color: root.active || root.emphasized ? root.accentColor : MusicTheme.text2
    opacity: 1
    font.family: Theme.fontFamily
    font.pixelSize: MusicTheme.icon
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
