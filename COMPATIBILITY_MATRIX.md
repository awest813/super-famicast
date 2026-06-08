# Compatibility Matrix

Use this file to track real behavior before and after each core change. Prefer short, repeatable notes over memory.

Status values:

- `OK`: works as expected.
- `Minor`: playable with small issue.
- `Major`: boots but serious issue.
- `Fail`: does not boot or crashes.
- `Unknown`: not tested yet.

Performance values should be measured on real Dreamcast hardware whenever possible. If an emulator is used, name it in `Tested On`.

| Game/Test ROM | Region | Mapper/Chip | Boot | Input | Graphics | Sound | SRAM/VMU | FPS | Frameskip | Tested On | Notes |
|---|---|---|---|---|---|---|---|---:|---:|---|---|
| CPU opcode test ROM | N/A | Base | Unknown | N/A | Unknown | N/A | N/A |  |  |  | Add exact ROM name/hash. |
| PPU timing test ROM | N/A | Base | Unknown | N/A | Unknown | N/A | N/A |  |  |  | Add exact ROM name/hash. |
| APU/SPC700 test ROM | N/A | Base | Unknown | N/A | N/A | Unknown | N/A |  |  |  | Add exact ROM name/hash. |
| Simple LoROM smoke game |  | LoROM | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Choose one common baseline game. |
| `Donkey Kong Country (USA).sfc` | USA | HiROM | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | SHA-256 `628147468C3539283197F58F03B94DF49758A332831857481EA9CC31645F0527`; internal title `DONKEY KONG COUNTRY`; use as HiROM smoke game. |
| `Donkey Kong Country (USA).sfc` | USA | HiROM | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Use as current fast-action/frame-pacing smoke game until broader SNES ROM set is available. |
| RPG SRAM smoke game |  | Base + SRAM | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Use for save/load verification. |
| Transparency/color math game |  | Base | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Use for PPU color math. |
| Mode 7 smoke game |  | Base | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Use for affine/background behavior. |
| Mouse smoke game |  | SNES Mouse | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Verify Dreamcast mouse path. |
| DSP-1 smoke game |  | DSP-1 | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Enhancement chip tier 1. |
| SuperFX smoke game |  | SuperFX | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Enhancement chip tier 2. |
| SA-1 smoke game |  | SA-1 | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | SH SA-1 builds; runtime behavior still untested. |
| S-DD1 smoke game |  | S-DD1 | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Verify decompression path. |
| C4 smoke game |  | C4 | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  | Watch expensive math/render helpers. |
| OBC1 smoke game |  | OBC1 | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  |  |
| S-RTC smoke game |  | S-RTC | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  |  |
| SPC7110 smoke game |  | SPC7110 | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  |  |
| SETA smoke game |  | SETA | Unknown | Unknown | Unknown | Unknown | Unknown |  |  |  |  |

## Regression Notes

Add dated notes here whenever behavior changes.

| Date | Build/Profile | Change | Result | Follow-up |
|---|---|---|---|---|
| 2026-06-08 | Baseline | Matrix created. | No ROMs tested yet. | Activate KOS toolchain and capture first baseline. |
| 2026-06-08 | Phase 0 local baseline | Build artifacts captured in `BASELINE_MANIFEST.md`. | Release/profile/debug/compat builds pass; runtime not tested. | Select ROM/test ROM set and run on target. |
| 2026-06-08 | ROM audit | Audited `C:\Users\allen\Downloads\Roms`. | One SNES candidate found: `Donkey Kong Country (USA).sfc`; handheld ROMs are out of scope. | Build local test disc and run in Flycast/real Dreamcast. |
