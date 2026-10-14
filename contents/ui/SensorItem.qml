import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.ksysguard.sensors as Sensors
import "gauges"
import "Tags.js" as Tags

GridLayout {
    id: si

    required property string sensorId
    required property string sensorName
    property string sensorTag: ""
    property bool inPanel: false
    property real panelThickness: 0

    required property var cfg
    readonly property real celsius: sensor.value === undefined || isNaN(Number(sensor.value)) ? NaN : Number(sensor.value)
    readonly property bool valid: !isNaN(celsius)

    readonly property var thresholds: cfg.thresholds.split(",").map(Number)
    readonly property var levelColors: cfg.levelColors.split(",")
    // 1..5 : one level for each threshold passed
    readonly property int level: {
        if (!valid) return 1;
        let l = 1;
        for (const t of thresholds) if (celsius >= t) l++;
        return Math.min(5, l);
    }
    readonly property color levelColor: levelColors[level - 1] ?? "red"
    readonly property real fraction: valid
        ? Math.max(0, Math.min(1, (celsius - cfg.minTemp) / Math.max(1, cfg.maxTemp - cfg.minTemp))) : 0
    readonly property color fg: cfg.useCustomTextColor ? cfg.textColor : Kirigami.Theme.textColor
    // In a panel the gauge scales to the panel thickness; otherwise use the configured size
    readonly property string effectiveTag: sensorTag.length > 0 ? sensorTag : Tags.autoTag(sensorId, sensorName)
    readonly property bool tagShown: cfg.showTag && effectiveTag.length > 0
    // In a panel, leave room for the tag label above the gauge
    readonly property int px: inPanel && panelThickness > 0
        ? Math.max(14, Math.round(panelThickness * (cfg.displayMode === "circle" ? 0.9 : 0.55) * (tagShown ? 0.75 : 1)))
        : Math.round(cfg.gaugeSize)

    readonly property string tempText: {
        if (!valid) return "–";
        return cfg.fahrenheit ? Math.round(celsius * 9 / 5 + 32) + "°F" : Math.round(celsius) + "°C";
    }

    // Tag above the gauge
    columns: 1
    columnSpacing: Kirigami.Units.smallSpacing
    rowSpacing: Kirigami.Units.smallSpacing

    Sensors.Sensor {
        id: sensor
        sensorId: si.sensorId
        updateRateLimit: si.cfg.updateRate * 1000
    }

    PlasmaComponents.Label {
        visible: si.tagShown
        text: si.effectiveTag
        color: si.fg
        opacity: 0.75
        font.bold: true
        font.pixelSize: Math.round(Math.max(9, (si.cfg.fontSize > 0 ? si.cfg.fontSize : Kirigami.Theme.defaultFont.pixelSize) * 0.85))
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    }

    // ---- gauge ----
    Loader {
        Layout.alignment: Qt.AlignHCenter
        sourceComponent: switch (si.cfg.displayMode) {
            case "circle": return circleC;
            case "topbar": return topbarC;
            case "line":   return lineC;
            case "fire":   return fireC;
            default:       return textC;
        }
    }

    Component { id: circleC
        Item {
            implicitWidth: si.px; implicitHeight: si.px
            CircleGauge { anchors.fill: parent; fraction: si.fraction; color: si.levelColor }
            TempLabel { host: si; anchors.centerIn: parent; font.pixelSize: Math.round(Math.max(8, si.px * 0.28)) }
        }
    }
    Component { id: topbarC
        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            BarGauge { Layout.preferredWidth: si.px * 1.6; thickness: Math.max(6, si.px * 0.18)
                       fraction: si.fraction; color: si.levelColor }
            TempLabel { host: si;}
        }
    }
    Component { id: lineC
        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            TempLabel { host: si;}
            BarGauge { Layout.preferredWidth: si.px * 1.6; thickness: 2
                       fraction: si.fraction; color: si.levelColor }
        }
    }
    Component { id: fireC
        ColumnLayout {
            spacing: 0
            FireIcon { Layout.alignment: Qt.AlignHCenter
                       Layout.preferredWidth: si.px; Layout.preferredHeight: si.px; level: si.level }
            TempLabel { host: si;}
        }
    }
    Component { id: textC
        TempLabel { host: si; color: si.levelColor; font.pixelSize: Math.round(Math.max(10, si.px * 0.45)) }
    }

    PlasmaComponents.Label {
        visible: si.cfg.showName && !si.inPanel && si.sensorName.length > 0
        text: si.sensorName
        color: si.fg
        opacity: 0.7
        elide: Text.ElideRight
        font.pixelSize: Math.round(Math.max(9, (si.cfg.fontSize > 0 ? si.cfg.fontSize : Kirigami.Theme.defaultFont.pixelSize) * 0.85))
        Layout.alignment: Qt.AlignHCenter
        Layout.maximumWidth: Math.max(si.px * 1.6, 60)
    }
}
