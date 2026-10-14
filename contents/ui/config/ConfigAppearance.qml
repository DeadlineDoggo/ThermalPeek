import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kquickcontrols as KQC

KCM.SimpleKCM {
    id: page
    property string cfg_displayMode
    property bool   cfg_showTag
    property string cfg_tagPosition
    property bool   cfg_showTemp
    property bool   cfg_showName
    property bool   cfg_fahrenheit
    property int    cfg_updateRate
    property int    cfg_minTemp
    property int    cfg_maxTemp
    property string cfg_thresholds
    property string cfg_levelColors
    property bool   cfg_useCustomTextColor
    property color  cfg_textColor
    property int    cfg_fontSize
    property int    cfg_gaugeSize

    property var colors: (cfg_levelColors || "").split(",")
    function setColor(i, c) { let a = colors.slice(); a[i] = String(c); cfg_levelColors = a.join(","); }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Display mode:")
            textRole: "text"; valueRole: "value"
            model: [
                { text: i18n("Circle gauge"),  value: "circle" },
                { text: i18n("Top bar"),       value: "topbar" },
                { text: i18n("Progress line"), value: "line" },
                { text: i18n("Fire icon (1–5)"), value: "fire" },
                { text: i18n("Text only"),     value: "text" }
            ]
            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(page.cfg_displayMode))
            onActivated: page.cfg_displayMode = currentValue
        }
        QQC2.SpinBox { Kirigami.FormData.label: i18n("Gauge size (px):"); from: 16; to: 256; value: page.cfg_gaugeSize
                       onValueModified: page.cfg_gaugeSize = value }
        QQC2.CheckBox { text: i18n("Show tags (CPU, NVME1…)"); checked: page.cfg_showTag; onToggled: page.cfg_showTag = checked }
        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Tag position:")
            enabled: page.cfg_showTag
            textRole: "text"; valueRole: "value"
            model: [
                { text: i18n("Above"),        value: "top" },
                { text: i18n("Below"),        value: "bottom" },
                { text: i18n("Left of icon"),  value: "left" },
                { text: i18n("Right of icon"), value: "right" }
            ]
            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(page.cfg_tagPosition))
            onActivated: page.cfg_tagPosition = currentValue
        }
        QQC2.CheckBox { text: i18n("Show temperature value (ignored in text-only mode)"); checked: page.cfg_showTemp
                        onToggled: page.cfg_showTemp = checked }
        QQC2.CheckBox { text: i18n("Show full sensor name (desktop only)"); checked: page.cfg_showName; onToggled: page.cfg_showName = checked }
        QQC2.CheckBox { text: i18n("Fahrenheit");       checked: page.cfg_fahrenheit; onToggled: page.cfg_fahrenheit = checked }
        QQC2.SpinBox { Kirigami.FormData.label: i18n("Update every (s):"); from: 1; to: 60; value: page.cfg_updateRate
                       onValueModified: page.cfg_updateRate = value }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Text") }
        QQC2.CheckBox { text: i18n("Custom text colour"); checked: page.cfg_useCustomTextColor
                        onToggled: page.cfg_useCustomTextColor = checked }
        KQC.ColorButton { Kirigami.FormData.label: i18n("Text colour:"); enabled: page.cfg_useCustomTextColor
                          color: page.cfg_textColor; onColorChanged: page.cfg_textColor = color }
        QQC2.SpinBox { Kirigami.FormData.label: i18n("Font size (0 = default):"); from: 0; to: 96; value: page.cfg_fontSize
                       onValueModified: page.cfg_fontSize = value }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Range") }
        QQC2.SpinBox { Kirigami.FormData.label: i18n("Bar empty at (°C):"); from: -20; to: 200; value: page.cfg_minTemp
                       onValueModified: page.cfg_minTemp = value }
        QQC2.SpinBox { Kirigami.FormData.label: i18n("Bar full at (°C):"); from: 0; to: 300; value: page.cfg_maxTemp
                       onValueModified: page.cfg_maxTemp = value }
        QQC2.TextField { Kirigami.FormData.label: i18n("Level thresholds (°C):"); text: page.cfg_thresholds
                         placeholderText: "45,60,75,90"; onTextEdited: page.cfg_thresholds = text }

        Kirigami.Separator { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Level colours") }
        Repeater {
            model: 5
            KQC.ColorButton {
                required property int index
                Kirigami.FormData.label: i18n("Level %1:", index + 1)
                color: page.colors[index] ?? "#ffffff"
                onColorChanged: page.setColor(index, color)
            }
        }
    }
}
