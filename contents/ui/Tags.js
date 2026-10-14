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
