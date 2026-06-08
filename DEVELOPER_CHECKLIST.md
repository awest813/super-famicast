# Developer Checklist

This is the working checklist for the first Super Famicast modernization sprint.

## Baseline Build

- [x] Activate a KOS/SH-ELF development shell.
- [x] Confirm `KOS_BASE` is set.
- [x] Confirm `make` is available.
- [x] Confirm `sh-elf-gcc` or `KOS_CC` is available.
- [x] Confirm `scramble` is available.
- [x] Confirm `mkisofs` is available.
- [x] Add repeatable build environment check script.
- [x] Run `make clean` from `src`.
- [x] Run `make BUILD_PROFILE=debug`.
- [x] Run `make BUILD_PROFILE=release`.
- [x] Run `make BUILD_PROFILE=profile`.
- [x] Run `make BUILD_PROFILE=compat`.
- [x] Run `make cdimg`.
- [x] Record tool versions and binary sizes in `BUILDING.md`.
- [x] Add repeatable DreamSDK import/build wrappers.
- [x] Capture Phase 0 artifact hashes in `BASELINE_MANIFEST.md`.
- [x] Add repeatable baseline capture script.

## SA-1 Build Path

- [x] Default baseline build to SH SA-1 core.
- [x] Keep SH SA-1 assembly available with `USE_SA1_ASM=1`.
- [x] Keep C SA-1 fallback available with `USE_SA1_ASM=0`.
- [x] Try `make USE_SA1_ASM=1` after toolchain activation.
- [x] Confirm `src/sh/sa1ops.S` assembles and links with DreamSDK R4.
- [ ] Add an SA-1 ROM/test-ROM compatibility check before trusting the assembly path at runtime.

## Baseline Measurements

- [x] Record build artifact sizes and hashes in `BASELINE_MANIFEST.md`.
- [x] Record historical compiler flag measurements from `src/simple_optimization_experiments.txt`.
- [ ] Pick exact ROM/test ROM names and hashes for `COMPATIBILITY_MATRIX.md` once ROMs are available.
- [ ] Measure one simple LoROM game with sound off on real Dreamcast or trusted emulator.
- [ ] Measure the same game with sound on on real Dreamcast or trusted emulator.
- [ ] Measure one HiROM game with sound off/on on real Dreamcast or trusted emulator.
- [ ] Measure one Mode 7 game with sound off/on on real Dreamcast or trusted emulator.
- [ ] Record FPS, frameskip, audio state, and tested hardware in `PERFORMANCE_BASELINE.md`.

## Safety Gates

- [ ] Verify ROM browser does not crash on non-ROM files.
- [ ] Verify SRAM save and load on VMU.
- [ ] Verify settings save and load on VMU.
- [ ] Verify CD swap flow.
- [ ] Verify controller mapping and pause/menu combos.
- [ ] Verify sound off remains stable.
- [ ] Verify sound on does not crash even if slow.

## First Code Targets After Baseline

- [x] Add initial frame/render/display counters behind `SFCAST_PROFILE`.
- [x] Add first deterministic frame signature hook behind `SFCAST_ACCURACY`.
- [x] Add `BUILD_PROFILE=accuracy`.
- [x] Add test ROM manifest and accuracy result log files.
- [ ] Gate optional systems for memory/performance experiments.
- [ ] Make max auto frameskip configurable.
- [ ] Improve VMU selection/error handling.
- [ ] Start sound sync investigation with measured buffer behavior.
