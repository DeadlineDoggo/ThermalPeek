# Thermal Peek

A KDE Plasma 6 widget that shows system temperatures in your panel (or on the desktop) as a circle
gauge, top bar, progress line, fire icon (levels 1–5) or plain text.

Sensors come from KSysGuard, so anything it can read works: CPU, GPU, NVMe/SSD drives, ACPI and
other lm-sensors devices.

## Features
- **5 display modes:** circle gauge, top bar, progress line, fire icon, text only
- **Any temperature sensor** from KSysGuard, including CPU average/min/max, per-core, GPU and drives
- **Tags** (CPU, GPU, NVME1…) with automatic suggestions, editable per sensor, shown above, below,
  left or right of the gauge
- **Reorderable** sensors on a dedicated *Order* page
- **Level colours:** 4 thresholds split temperatures into 5 levels, each with its own colour
- **Adjustable spacing** between sensors and between tag and gauge
- Optional temperature value (hide it under the fire icon, for example), °C / °F, custom text
  colour, font size, gauge size and update rate
- **Missing sensors are handled gracefully.** If a sensor disappears (for example the dGPU is
  switched off with envycontrol or a MUX switch), it is hidden on the panel but stays saved, and
  it shows up again when it comes back
- In a panel the gauge scales to the panel thickness

## Requirements
- KDE Plasma 6 (developed and tested on 6.7.5)
- KSysGuard sensors (`ksystemstats`, `libksysguard`). Drive and board sensors need `lm_sensors`
  data. NVIDIA GPU temperature needs `nvidia-utils`.

## Install
From the project directory:

```bash
kpackagetool6 -t Plasma/Applet -i .
```

Update after pulling changes or editing files:

```bash
kpackagetool6 -t Plasma/Applet -u .
```

Remove:

```bash
kpackagetool6 -t Plasma/Applet -r org.kde.thermalpeek
```

Reload the shell so changes show up:

```bash
systemctl --user restart plasma-plasmashell.service
# or: kquitapp6 plasmashell && kstart plasmashell
```

## Usage
1. Right-click the panel → **Add Widgets…** → search **Thermal Peek** → drag it into the panel.
2. Right-click the widget → **Configure Thermal Peek…**
3. Configure it on these pages:
   - **Sensors:** tick the temperature sensors to show and edit their tags.
   - **Order:** move sensors up or down. First is left (horizontal panel) or top (vertical panel).
   - **Appearance:** display mode, tag position, spacing, colours, thresholds and range.

Changes made on the *Sensors* page need **Apply** before they appear on the *Order* page.

Hover the widget to see the full sensor names.

### Picking sensors
| Want | Choose |
| --- | --- |
| Whole CPU | `cpu/all/maximumTemperature` (hottest core) or `averageTemperature` |
| NVMe drive | the **Composite** entry of `nvme-pci-…`. Sensor 1 and 2 are individual chips. |
| SATA SSD / HDD | `drivetemp-scsi-…` (needs the `drivetemp` module, see below) |
| GPU | `gpu/gpuN/temperature` |
| Motherboard / chipset | `acpitz-acpi-0` |

### Which sensor is which drive?
- **NVMe** drives appear as `nvme-pci-XXXX` (`e100` is PCI `e1:00.0`). List them with:
  ```bash
  for n in /sys/class/nvme/nvme*; do echo "$(basename $n)  $(cat $n/model)  $(basename $(readlink -f $n/device))"; done
  ```
- **SATA SSDs and HDDs** (also many USB/SCSI drives) appear as `drivetemp-scsi-H:C:T:L` once the
  kernel `drivetemp` module is loaded. It is not always loaded by default:
  ```bash
  sudo modprobe drivetemp                                  # load now
  echo drivetemp | sudo tee /etc/modules-load.d/drivetemp.conf   # load on every boot
  lsblk -d -o NAME,MODEL,SIZE,TRAN,HCTL                    # HCTL = H:C:T:L of the sensor name
  ```
  Some drives, USB enclosures and RAID controllers don't report a temperature at all. Then no
  sensor exists for them and the drive can't be shown (`smartctl -A /dev/sdX` may still work, see
  the roadmap).
- Run `sensors` to see everything lm-sensors knows about.

## Configuration notes
- **Level thresholds:** default `45,60,75,90` °C give levels 1–5. Each level has a colour, and the
  fire icon uses the matching `fire-N.svg`.
- **Bar range:** the temperature at which a bar or circle is empty and full.
- **Update rate:** how often values refresh, in seconds.

## Development
Test without installing (needs `plasma-sdk`):

```bash
plasmoidviewer -a . -l topedge     # or: -f horizontal
```

Project layout:

```
metadata.json                  plugin id: org.kde.thermalpeek
contents/config/main.xml       settings schema
contents/config/config.qml     config page list (Sensors, Order, Appearance)
contents/ui/main.qml           layout of all sensors, panel handling
contents/ui/SensorItem.qml     one sensor: level logic, tag and chosen gauge
contents/ui/TempLabel.qml      temperature text
contents/ui/Tags.js            automatic tag suggestions
contents/ui/gauges/            CircleGauge, BarGauge, FireIcon
contents/ui/config/            Sensors, Order and Appearance pages
contents/icons/                fire-1..5.svg (fire levels), order.svg (config page icon)
```

## Roadmap
- C++ QML plugin reading `/sys/class/hwmon`, `thermal_zone*`, NVML and `smartctl` (drives without
  a kernel sensor) for sources
  KSysGuard doesn't expose
- Per-sensor display mode and name

## License
MIT (see `metadata.json`). Add a `LICENSE` file before publishing.
