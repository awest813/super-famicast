param(
    [string] $RomRoot = "C:\Users\allen\Downloads\Roms"
)

$ErrorActionPreference = "Stop"

$python = @'
import os, zipfile, hashlib, json, sys

root = sys.argv[1]

def sha_bytes(data):
    return hashlib.sha256(data).hexdigest().upper()

def snes_header_info(data):
    if len(data) % 1024 == 512:
        data = data[512:]
    candidates = []
    for kind, off in (("LoROM", 0x7FC0), ("HiROM", 0xFFC0), ("ExHiROM", 0x40FFC0)):
        if off + 0x40 <= len(data):
            header = data[off:off + 0x40]
            title = header[:21].decode("ascii", "replace").strip(" \0")
            map_mode = header[0x15]
            rom_type = header[0x16]
            rom_size = header[0x17]
            sram_size = header[0x18]
            checksum = header[0x1E] | (header[0x1F] << 8)
            complement = header[0x1C] | (header[0x1D] << 8)
            score = 0
            if title and all((32 <= ord(c) < 127) or c == "\ufffd" for c in title):
                score += 2
            if (checksum ^ complement) == 0xFFFF:
                score += 4
            if map_mode in (0x20, 0x21, 0x23, 0x25, 0x30, 0x31, 0x32, 0x35):
                score += 2
            candidates.append((score, kind, title, map_mode, rom_type, rom_size, sram_size, checksum, complement))
    if not candidates:
        return None
    score, kind, title, map_mode, rom_type, rom_size, sram_size, checksum, complement = max(candidates, key=lambda item: item[0])
    return {
        "mapper": kind,
        "title": title,
        "map_mode": f"0x{map_mode:02X}",
        "rom_type": f"0x{rom_type:02X}",
        "rom_size_exp": rom_size,
        "sram_size_exp": sram_size,
        "checksum": f"0x{checksum:04X}",
        "complement": f"0x{complement:04X}",
        "score": score,
    }

results = []
counts = {".sfc": 0, ".smc": 0, ".gb": 0, ".gbc": 0, ".gba": 0, ".zip": 0, "zip_snes_entries": 0}

for dirpath, _, files in os.walk(root):
    for name in files:
        path = os.path.join(dirpath, name)
        ext = os.path.splitext(name)[1].lower()
        if ext in counts:
            counts[ext] += 1
        if ext in (".sfc", ".smc"):
            with open(path, "rb") as source:
                data = source.read()
            results.append({
                "kind": "snes-file",
                "path": path,
                "name": name,
                "bytes": len(data),
                "sha256": sha_bytes(data),
                "snes": snes_header_info(data),
            })
        elif ext == ".zip":
            with zipfile.ZipFile(path) as archive:
                for info in archive.infolist():
                    entry_ext = os.path.splitext(info.filename)[1].lower()
                    if entry_ext in (".sfc", ".smc"):
                        data = archive.read(info)
                        counts["zip_snes_entries"] += 1
                        results.append({
                            "kind": "snes-zip-entry",
                            "zip": path,
                            "entry": info.filename,
                            "name": os.path.basename(info.filename),
                            "bytes": len(data),
                            "sha256": sha_bytes(data),
                            "snes": snes_header_info(data),
                        })

print(json.dumps({"counts": counts, "snes": results}, indent=2))
'@

if (!(Test-Path $RomRoot)) {
    throw "ROM root was not found: $RomRoot"
}

$python | python - $RomRoot
