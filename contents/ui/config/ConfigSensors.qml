import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kitemmodels as KItemModels
import org.kde.ksysguard.sensors as Sensors

KCM.ScrollViewKCM {
    id: page
    property string cfg_sensors
    property string cfg_sensorsDefault

    property var selected: JSON.parse(cfg_sensors || "[]")
    function isSelected(id) { return selected.some(s => s.sensorId === id); }
    function toggle(id, name, on) {
        let list = selected.filter(s => s.sensorId !== id);
        if (on) list.push({ sensorId: id, name: name });
        selected = list;
        cfg_sensors = JSON.stringify(list);
    }

    Sensors.SensorTreeModel { id: treeModel }
    KItemModels.KDescendantsProxyModel { id: flatModel; model: treeModel }
    KItemModels.KSortFilterProxyModel {
        id: tempModel
        sourceModel: flatModel
        filterRowCallback: (row, parent) => {
            const idx = sourceModel.index(row, 0);
            const id = sourceModel.data(idx, Sensors.SensorTreeModel.SensorId);
            const disp = sourceModel.data(idx, Qt.DisplayRole);
            return id.length > 0 && disp.includes("(°C)") && !disp.includes("[");
        }
    }

    // "Category / Subcategory: Sensor" label
    function labelFor(row) {
        const pidx = tempModel.index(row, 0);
        let name = tempModel.data(pidx, Qt.DisplayRole).replace(" (°C)", "");
        let c = flatModel.mapToSource(tempModel.mapToSource(pidx));
        let sub = null;
        while (c.parent.valid) { sub = c; c = c.parent; }
        const section = treeModel.data(c, Qt.DisplayRole);
        if (sub && tempModel.data(pidx, Sensors.SensorTreeModel.SensorId).includes("lmsensors"))
            name = treeModel.data(sub, Qt.DisplayRole) + ": " + name;
        return { name: name, section: section };
    }

    header: Kirigami.InlineMessage {
        visible: true
        text: i18n("Tick the temperature sensors to show. Sensors come from KSysGuard (lm-sensors, GPU, disks).")
    }

    view: ListView {
        model: tempModel
        clip: true
        section.property: "dummy"
        delegate: QQC2.CheckDelegate {
            required property int index
            readonly property var info: page.labelFor(index)
            readonly property string sid: tempModel.data(tempModel.index(index, 0), Sensors.SensorTreeModel.SensorId)
            width: ListView.view.width
            checked: page.isSelected(sid)
            onToggled: page.toggle(sid, info.name, checked)

            // Live probe, exists only while this config window is open
            Sensors.Sensor { id: probe; sensorId: sid; updateRateLimit: 1000 }
            readonly property bool active: probe.value !== undefined && !isNaN(Number(probe.value))

            contentItem: ColumnLayout {
                spacing: 0
                QQC2.Label { text: info.section + " — " + info.name; Layout.fillWidth: true; elide: Text.ElideRight }
                QQC2.Label {
                    Layout.fillWidth: true
                    font: Kirigami.Theme.smallFont
                    color: active ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.negativeTextColor
                    text: (active ? i18n("● Active: %1 °C", Number(probe.value).toFixed(1)) : i18n("○ No data")) + "   (" + sid + ")"
                    elide: Text.ElideRight
                }
            }
        }
    }
}
