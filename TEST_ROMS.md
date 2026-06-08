# Test ROM Manifest

Use this file to list exact test ROMs and hashes before relying on accuracy signatures. Do not record commercial ROM contents here; record only names, source projects, versions, hashes, and notes.

## Required Core Tests

| Test | Source/Project | File | SHA-256 | Purpose | Status |
|---|---|---|---|---|---|
| 65c816 opcode behavior | TBD | TBD | TBD | CPU flags, addressing modes, decimal mode, stack behavior. | Needed |
| DMA/HDMA behavior | TBD | TBD | TBD | DMA timing and register effects. | Needed |
| NMI/IRQ timing | TBD | TBD | TBD | Interrupt timing and event scheduling. | Needed |
| WRAM/VRAM/OAM/CGRAM access | TBD | TBD | TBD | Memory/register access timing and side effects. | Needed |
| PPU modes/color math/windows | TBD | TBD | TBD | Rendering behavior signatures and screenshots. | Needed |
| SPC700/APU timers/DSP | TBD | TBD | TBD | APU execution, timers, DSP register behavior. | Needed |

## Smoke ROM Categories

| Category | Candidate | SHA-256 | Notes |
|---|---|---|---|
| Simple LoROM | TBD | TBD | Basic boot/input/render sanity. |
| HiROM | `Donkey Kong Country (USA).sfc` | `628147468C3539283197F58F03B94DF49758A332831857481EA9CC31645F0527` | Audited from `C:\Users\allen\Downloads\Roms`; internal title `DONKEY KONG COUNTRY`, map mode `0x31`, checksum `0x2BCC`, complement `0xD433`. |
| Fast action | `Donkey Kong Country (USA).sfc` | `628147468C3539283197F58F03B94DF49758A332831857481EA9CC31645F0527` | Usable for early frame pacing and scrolling smoke tests. |
| SRAM RPG | TBD | TBD | VMU save/load verification. Current ROM folder has no SNES RPG/SRAM candidate. |
| Transparency/color math | TBD | TBD | PPU blending/window behavior. |
| Mode 7 | TBD | TBD | Affine background behavior. |
| SNES Mouse | TBD | TBD | Dreamcast mouse path. |
| DSP-1 | TBD | TBD | Enhancement chip tier 1. |
| SuperFX | TBD | TBD | Enhancement chip tier 2. |
| SA-1 | TBD | TBD | Verify SH SA-1 runtime behavior. |
| S-DD1 | TBD | TBD | Decompression path. |
| C4 | TBD | TBD | Math/render helper behavior. |
| OBC1 | TBD | TBD | Object chip behavior. |
| S-RTC | TBD | TBD | Clock chip behavior. |
| SPC7110 | TBD | TBD | Mapping/decompression behavior. |
| SETA | TBD | TBD | SETA DSP/RISC behavior. |

## Audited Local ROM Folder

Last audited on 2026-06-08 from `C:\Users\allen\Downloads\Roms`.

| Platform | Count | Notes |
|---|---:|---|
| SNES `.sfc` | 1 | `Donkey Kong Country (USA).sfc`; usable as HiROM / fast-action smoke candidate. |
| SNES `.smc` | 0 | None found. |
| SNES entries inside `.zip` | 0 | Six zip files were inspected; none contained `.sfc` or `.smc` entries. |
| GB `.gb` | 2 | Out of scope for Super Famicast. |
| GBC `.gbc` | 3 | Out of scope for Super Famicast. |
| GBA `.gba` | 3 | Out of scope for Super Famicast. |

Out-of-scope handheld files found:

- `Bomberman Max - Blue Champion (USA).gbc`
- `Donkey Kong Country (USA, Europe) (En,Fr,De,Es,It).gbc`
- `Legend of the River King GB (USA) (SGB Enhanced).gb`
- `Legend of Zelda, The - Link's Awakening (USA, Europe) (Rev 2).gb`
- `Legend of Zelda, The - Oracle of Seasons (USA, Australia).gbc`
- `F-Zero - GP Legend (USA).gba`
- `Mario Tennis - Power Tour (USA, Australia) (En,Fr,De,Es,It).gba`
- `Tekken Advance (USA).gba`
