pragma Singleton
import QtQuick
import qs.config

// Shared Orpheus visual tokens. Everything below is derived from the shell's
// generated Theme/Settings so the three music surfaces stay in the same
// design system as the bar and the notification center.
QtObject {
  readonly property string textFont: "Bricolage Grotesque"
  readonly property string iconFont: Theme.fontFamily

  // Type scale — deliberately generous for legibility. Nothing below 12 px.
  readonly property int hero: 25
  readonly property int title: 22
  readonly property int heading: 17
  readonly property int section: 15
  readonly property int body: 15
  readonly property int bodyMinor: 14
  readonly property int caption: 13
  readonly property int micro: 12
  readonly property int icon: 18
  readonly property int iconSmall: 15
  readonly property int iconLarge: 24

  // Surfaces and ink. Mint marks state; artwork stays naturally colorful.
  // Orpheus использует те же зелёные слои, что бар и App Center: никакого
  // отдельного почти-чёрного полотна и собственной палитры.
  readonly property color canvas: Qt.rgba(Theme.panelAlt.r, Theme.panelAlt.g, Theme.panelAlt.b, 0.95)
  readonly property color surface: Theme.panel
  readonly property color surfaceAlt: Qt.rgba(Theme.pillHover.r, Theme.pillHover.g, Theme.pillHover.b, 0.95)
  readonly property color surfaceRaised: Qt.rgba(Theme.section.r, Theme.section.g, Theme.section.b, 0.96)
  readonly property color surfaceActive: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.16)
  readonly property color surfaceHover: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.08)
  readonly property color border: Theme.border
  readonly property color borderStrong: Qt.rgba(Theme.primaryDim.r, Theme.primaryDim.g, Theme.primaryDim.b, 0.52)
  readonly property color divider: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.13)
  readonly property color text: Theme.text
  readonly property color text2: Theme.textDim
  readonly property color text3: Qt.rgba(Theme.textDim.r, Theme.textDim.g, Theme.textDim.b, 0.86)
  readonly property color accent: Theme.primary
  readonly property color accentText: Theme.inverse
  readonly property color lavender: Theme.secondary
  readonly property color danger: Theme.error

  // Geometry.
  readonly property int radiusPopup: Settings.popupRadius
  readonly property int radiusCard: 14
  readonly property int radiusControl: 10
  readonly property int radiusThumb: 8
  readonly property int pillRadius: 999
  readonly property int pad: 16
  readonly property int padTight: 10
  readonly property int gap: 10
  readonly property int gapTight: 6
  readonly property int navWidth: 196
  readonly property int navHeight: 40
  readonly property int controlHeight: 38
  readonly property int buttonSize: 32
  readonly property int buttonLarge: 44
  readonly property int rowHeight: 60
  readonly property int queueRowHeight: 56
  readonly property int coverPlayer: 112
  readonly property int tileWidth: 148
  readonly property int tileHeight: 198

  // Motion follows shell accessibility settings.
  readonly property int fast: Settings.reducedMotion ? 0 : 110
  readonly property int duration: Settings.reducedMotion ? 0 : 150
  readonly property int slow: Settings.reducedMotion ? 0 : 220
}
