# Baseline Manifest

Phase 0 local preservation snapshot captured on 2026-06-08.

This manifest records the current buildable Dreamcast artifacts before deeper emulator rewrites. Runtime FPS and compatibility are not filled in here because no ROM set, emulator run, or real Dreamcast hardware pass has been provided yet.

## Source Identity

- Git HEAD at capture start: `851cd7bd575398e87bf070288e44aa5900f1dd94`
- Git short HEAD: `851cd7b`
- Working tree: dirty before this baseline work; generated binary artifacts were already modified and remain intentionally untouched except for rebuild outputs.

## Toolchain

- DreamSDK: R4 `4.0.11.2508`, built `2025-08-30 22:23:42`
- DreamSDK home: `C:\DreamSDK`
- KOS version: `2.2.1`
- KOS base: `C:\DreamSDK\opt\dreamsdk`
- KOS CC: `C:\DreamSDK\opt\toolchains\dc\sh-elf\bin\sh-elf-gcc`
- KOS genromfs: `C:\DreamSDK\opt\toolchains\dc\kos\utils\genromfs\genromfs`
- SH-ELF GCC: `13.2.0`
- Binutils/as: `2.43`
- GNU Make: `4.4.1`
- mkisofs: `2.01-bootcd.ru`

## Verified Commands

From PowerShell:

```powershell
.\tools\check_build_env.ps1
.\tools\build.ps1 -Profile debug -Clean
.\tools\build.ps1 -Profile profile -Clean
.\tools\build.ps1 -Profile compat -Clean
.\tools\build.ps1 -Profile release -Clean -CdImage
```

All four build profiles and `data.iso` generation succeeded with SH SA-1 assembly as the default.

## Artifact Hashes

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| `src\superfamicast.elf` | 1115364 | `5E42EDC4D326B34DE8429115D6F8237B622B0128B393876134D6EE0C66F4DE30` |
| `src\bin\raw.bin` | 1114632 | `1A60587EABC787868EAE6C32219D3A28CEEDBD2177B46AABEE7A787FDBE9D08A` |
| `src\bin\1ST_READ.BIN` | 1114632 | `ED51F5E98C720E2AB44C0162D8443572F034E19B29AA2921A1E1CB18A37EB787` |
| `src\cd\1ST_READ.BIN` | 1114632 | `ED51F5E98C720E2AB44C0162D8443572F034E19B29AA2921A1E1CB18A37EB787` |
| `src\data.iso` | 6316032 | `600D80A43687358298ECD5C5E5EDB6085584FBC3785B04DB3310139DBDD342D1` |
| `src\romdisk.img` | 67584 | `0964FDA3AE12C5EC556543EAACCD6AAD41C512787D1047941A0A8A504D25068D` |

## Known Runtime Gaps

- Real Dreamcast boot: not tested.
- Emulator boot: not tested.
- ROM compatibility matrix: created but not populated with real ROM hashes/results.
- FPS with sound off/on: not measured.
- SRAM/VMU, settings VMU, CD swap, controller mapping, mouse support, and sound stability: not runtime-tested in this snapshot.

## Repeat Capture

Run:

```powershell
.\tools\capture_baseline.ps1
```
