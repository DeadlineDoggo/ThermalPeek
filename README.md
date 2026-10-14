# Thermal Peek

A KDE Plasma 6 widget that shows system temperatures in the panel (or on the desktop) as a
circle gauge, top bar, progress line, fire icon (levels 1–5) or plain text.

Unlike *Thermal Monitor*, the look is configurable: display mode, text/level colours, font size,
thresholds, bar range, °C/°F and update rate.

## Requirements
- KDE Plasma 6 (tested on 6.7.5)
- `lm_sensors` data available to KSysGuard (hwmon sensors appear under *Hardware Sensors*)

## Install / update (kpackagetool6)
```bash
# first install
kpackagetool6 -t Plasma/Applet -i .
# after editing files
kpackagetool6 -t Plasma/Applet -u .
# remove
kpackagetool6 -t Plasma/Applet -r org.kde.thermalpeek
```
Then reload the shell so changes show up:
```bash
systemctl --user restart plasma-plasmashell.service   # or: kquitapp6 plasmashell && kstart plasmashell
```

## Add to the taskbar
1. Right-click the panel → **Add Widgets…** → search **Thermal Peek** → drag into the panel
   (or right-click panel → *Enter Edit Mode* → *Add Widgets*).
2. Right-click the widget → **Configure Thermal Peek…**
3. *Sensors*: tick the temperature sensors. *Appearance*: pick the display mode and colours.

In a panel the gauge scales to the panel thickness; hover the widget to see the sensor names.

## Develop
Without installing, test in a window (needs `plasma-sdk`):
```bash
plasmoidviewer -a . -l topedge     # or: -f horizontal
```

## Layout
```
metadata.json                  plugin id: org.kde.thermalpeek
contents/config/main.xml       settings schema
contents/ui/main.qml           layout of all sensors, panel handling
contents/ui/SensorItem.qml     one sensor: level logic + chosen gauge
contents/ui/gauges/            CircleGauge, BarGauge, FireIcon
contents/ui/config/            Sensors and Appearance config pages
contents/icons/fire-1..5.svg   fire levels
```

## Levels
Thresholds (default `45,60,75,90` °C) split temperatures into levels 1–5. Each level has a
colour, and the fire icon uses the matching `fire-N.svg`.

## Roadmap
- C++ QML plugin reading `/sys/class/hwmon`, `thermal_zone*`, NVML, `smartctl` for sources
  KSysGuard doesn't expose
- Per-sensor display mode and name
