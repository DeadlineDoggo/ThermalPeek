.pragma library

// Suggest a short tag: CPU, C1.., NVME1.., GPU.., else first word
function autoTag(id, name) {
    let m;
    if (id.startsWith("cpu/all")) return "CPU";
    if ((m = id.match(/^cpu\/cpu(\d+)\//))) return "C" + (Number(m[1]) + 1);
    if (/gpu/i.test(id + name)) return "GPU";
    if (/nvme/i.test(name)) { m = name.match(/nvme\D*(\d+)/i); return "NVME" + (m ? Number(m[1]) + 1 : ""); }
    if (/acpi/i.test(name)) return "ACPI";
    return name.split(/[ :]/)[0].toUpperCase().slice(0, 6);
}

// Glyph names (contents/icons/glyphs/<name>.svg), in the order shown in the pickers
var glyphs = ["cpu", "gpu", "nvme", "hdd", "ssd", "motherboard", "bolt", "unknown", "point"];

// Guess the glyph for a sensor
function autoIcon(id, name) {
    if (id.startsWith("cpu/")) return "cpu";
    if (/gpu/i.test(id + name)) return "gpu";
    if (/nvme/i.test(id + name)) return "nvme";
    if (/ssd/i.test(name)) return "ssd";
    if (/drivetemp|hdd|sd[a-z]/i.test(id + name)) return "hdd";
    if (/acpi|board|chipset|mobo|pch/i.test(id + name)) return "motherboard";
    return "unknown";
}

// width / height of each glyph
var glyphAspect = {
    "cpu": 1.000,
    "gpu": 1.525,
    "nvme": 2.071,
    "hdd": 0.923,
    "ssd": 0.815,
    "motherboard": 1.000,
    "bolt": 0.759,
    "unknown": 1.000,
    "point": 1.000
};
