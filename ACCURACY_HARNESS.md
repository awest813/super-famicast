# Accuracy Harness

Phase 1 starts with lightweight deterministic signatures from the Dreamcast build. The first pass is intentionally small: it prints one line per completed frame when built with `BUILD_PROFILE=accuracy`.

## Build

From PowerShell:

```powershell
.\tools\build.ps1 -Profile accuracy -Clean
```

This defines `SFCAST_ACCURACY` and keeps release builds free of the extra hashing and logging.

## Output

Each completed frame prints:

```text
SFCAST_ACCURACY frame=... pc=... a=... x=... y=... s=... d=... db=... p=... cpu_cycles=... vc=... apu_pc=... apu_ya=... apu_x=... apu_s=... apu_p=... apu_cycles=... wram=... vram=... fillram=... sram=... apuram=... apudsp=... cgram=... oam=... ppu_mode=... brightness=... forced_blank=... render=...
```

The hashes use FNV-1a over:

- WRAM: `Memory.RAM`, 128 KiB.
- VRAM: `Memory.VRAM`, 64 KiB.
- PPU/CPU register mirror: `Memory.FillRAM`, 32 KiB.
- SRAM: current `Memory.SRAMMask + 1`, capped at 128 KiB.
- APU RAM: `IAPU.RAM`, 64 KiB.
- APU DSP registers.
- CGRAM.
- OAM object table.

## Intended Workflow

1. Choose a test ROM entry from `TEST_ROMS.md`.
2. Boot the accuracy build.
3. Run a fixed number of frames after reset or ROM load.
4. Capture `SFCAST_ACCURACY` lines from serial/log output.
5. Store expected signatures in `ACCURACY_RESULTS.md`.
6. Compare signatures after CPU, PPU, APU, memory-map, or optimization changes.

## Limits

- This is a signature harness, not a pass/fail test runner yet.
- It does not yet automate ROM loading, frame counts, screenshots, or host-side reference comparison.
- Hashes are useful only when the same ROM, settings, input state, and frame count are used.
