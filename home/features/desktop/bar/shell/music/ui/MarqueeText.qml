import QtQuick
import qs.config

Item {
  id: root
  property string textValue: ""
  property color textColor: Theme.text
  property int fontSize: Theme.fontSize
  property bool animate: true
  implicitWidth: 300
  implicitHeight: 20
  property int travel: Math.max(0, label.implicitWidth - root.width + 12)
  clip: true

  Text {
    id: label
    text: root.textValue
    color: root.textColor
    font.family: Theme.fontFamily
    font.pixelSize: root.fontSize
    verticalAlignment: Text.AlignVCenter
    anchors.verticalCenter: parent.verticalCenter

    SequentialAnimation on x {
      id: marquee
      running: root.animate && label.implicitWidth > root.width + 4
      loops: Animation.Infinite
      PauseAnimation { duration: 1000 }
      NumberAnimation {
        to: -root.travel
        duration: Math.max(2600, root.travel * 38)
        easing.type: Easing.InOutSine
      }
      PauseAnimation { duration: 900 }
      NumberAnimation {
        to: 0
        duration: 900
        easing.type: Easing.InOutSine
      }
    }
  }

  onTextValueChanged: {
    label.x = 0;
    if (root.animate && label.implicitWidth > root.width + 4) marquee.restart();
    else marquee.stop();
  }
}
