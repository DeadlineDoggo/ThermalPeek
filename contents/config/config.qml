import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory { name: i18n("Sensors");    icon: "sensors";             source: "config/ConfigSensors.qml" }
    ConfigCategory { name: i18n("Appearance"); icon: "preferences-desktop-color"; source: "config/ConfigAppearance.qml" }
}
