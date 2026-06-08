# Performance Baseline

Use this file to record measured performance. The current README says many games reach full speed only with frameskip, and sound is slow/out of sync. This sheet exists to turn that into numbers.

## Test Environment

Fill this in for each baseline pass:

- Date:
- Git commit:
- Build profile: release baseline now builds.
- KOS version: 2.2.1
- SH-ELF GCC version: 13.2.0
- Hardware/emulator:
- Video cable/display:
- Sound enabled:
- Bilinear filtering:
- Frameskip mode:
- Max auto frameskip:
- ROM media:
- VMU attached:

## Current Known State

- DreamSDK R4 (4.0.11.2508) builds the release, profile, compat, and `data.iso` targets.
- Phase 0 build artifact sizes and SHA-256 hashes are captured in `BASELINE_MANIFEST.md`.
- Many games emulate at full speed with frameskip.
- Sound exists, but is documented as not synced and not fast.
- Bilinear filtering is documented as not affecting performance.
- Auto-save SRAM can cause a short gameplay pause.
- Auto frameskip currently has a maximum of 10 skipped frames.
- Prior compiler flag experiments recorded roughly 21-24 FPS in `src/simple_optimization_experiments.txt`, with best recorded value from removing `-fno-strict-aliasing`.

## Phase 0 Build Baseline

| Artifact | Bytes | Notes |
|---|---:|---|
| `src/superfamicast.elf` | 1115364 | Release, SH SA-1 default. |
| `src/bin/1ST_READ.BIN` | 1114632 | Scrambled boot binary. |
| `src/cd/1ST_READ.BIN` | 1114632 | CD tree boot binary. |
| `src/data.iso` | 6316032 | Generated with `make cdimg`. |

Runtime FPS/audio measurements remain pending until a ROM/test ROM set and real Dreamcast or trusted emulator target are available.

## Measurements

| Game/Test ROM | Build/Profile | Sound | Bilinear | Frameskip | FPS Min | FPS Avg | FPS Max | Audio State | Notes |
|---|---|---:|---:|---|---:|---:|---:|---|---|
| Simple LoROM smoke game | Baseline | Off | Off | Auto |  |  |  | N/A |  |
| Simple LoROM smoke game | Baseline | On | Off | Auto |  |  |  | Unknown |  |
| `Donkey Kong Country (USA).sfc` | Baseline | Off | Off | Auto |  |  |  | N/A | HiROM candidate; SHA-256 in `TEST_ROMS.md`. |
| `Donkey Kong Country (USA).sfc` | Baseline | On | Off | Auto |  |  |  | Unknown | HiROM candidate; SHA-256 in `TEST_ROMS.md`. |
| `Donkey Kong Country (USA).sfc` | Baseline | Off | Off | Auto |  |  |  | N/A | Fast-action/frame-pacing candidate. |
| `Donkey Kong Country (USA).sfc` | Baseline | On | Off | Auto |  |  |  | Unknown | Fast-action/frame-pacing candidate. |
| Mode 7 smoke game | Baseline | Off | Off | Auto |  |  |  | N/A |  |
| Mode 7 smoke game | Baseline | On | Off | Auto |  |  |  | Unknown |  |

## Hotspot Counters To Add

Add low-overhead counters before major rewrites:

- Main CPU execution time per frame. Initial `SFCAST_PROFILE` counter added.
- PPU render time per frame. Initial `SFCAST_PROFILE` counter added.
- APU/SPC700 execution time per frame.
- DSP/mixing/output time per frame.
- Final blit/PVR submit time per frame. Initial `SFCAST_PROFILE` counter added around `display_snes_screen()`.
- VMU save duration.
- ROM load/decompression duration.

To enable initial counters:

```sh
make BUILD_PROFILE=profile
```

The profile build succeeds and prints one `SFCAST_PROFILE` line per second with average CPU-loop, render, and display times in microseconds.

## Compiler Flag Experiment Log

Record one change at a time and only trust results from the same game, settings, and hardware.

| Date | Build Flags Changed | Game/Test | Sound | FPS Avg | Result | Keep? |
|---|---|---|---:|---:|---|---|
| Historical | Removed `-fno-optimize-sibling-calls` | Unknown | Unknown | 22 | From `src/simple_optimization_experiments.txt`. | Retest |
| Historical | Changed `-O3` to `-Os` | Unknown | Unknown | 21 | From `src/simple_optimization_experiments.txt`. | Retest |
| Historical | Added `-fforce-addr` | Unknown | Unknown | 23 | From `src/simple_optimization_experiments.txt`. | Retest |
| Historical | Added `-fmove-all-movables` | Unknown | Unknown | 21 | From `src/simple_optimization_experiments.txt`. | Retest |
| Historical | Removed `-fno-strict-aliasing` | Unknown | Unknown | 24 | From `src/simple_optimization_experiments.txt`. Risky for emulator code; needs correctness tests. | Retest |
| Historical | Added `-funroll-loops` | Unknown | Unknown | 22 | From `src/simple_optimization_experiments.txt`. | Retest |
