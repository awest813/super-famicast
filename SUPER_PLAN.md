# Super Famicast Super Plan

Goal: make Super Famicast an extremely accurate, lightweight, high-performance SNES emulator for the Sega Dreamcast, while staying realistic about the Dreamcast's SH-4 CPU, AICA sound hardware, 16 MB main RAM, 8 MB video RAM, GD/CD access patterns, and KOS toolchain limits.

This plan combines the current README goals, feature notes, future-work hints, build notes, SH4 optimization notes, and known pain points into one phased roadmap.

## North Star

Super Famicast should become:

- Accurate enough that normal commercial SNES games behave like real hardware unless a documented Dreamcast performance mode is enabled.
- Fast enough that common non-enhancement-chip games run full speed on real Dreamcast hardware with sound enabled and minimal frameskip.
- Lightweight enough to fit the Dreamcast memory budget without large lookup tables, heavyweight UI systems, or unnecessary runtime allocation.
- Honest about tradeoffs: accuracy mode is the reference; performance mode may use safe shortcuts only when they do not break common games.

## Success Metrics

- Reproducible clean build from source using a documented KOS + SH-ELF toolchain.
- Stable boot on real Dreamcast, emulator, and debug target where available.
- Full-speed target for popular LoROM/HiROM games: 60 fps NTSC or 50 fps PAL with sound enabled, using frameskip only as a fallback.
- Sound target: synced, stable, no runaway latency, no severe crackling in baseline games.
- Accuracy target: pass core CPU/APU/PPU behavior tests where practical, plus a curated compatibility list of real games.
- Memory target: predictable memory map, no avoidable heap churn during gameplay, ROM loading failures handled cleanly.
- UX target: ROM loading, SRAM/VMU saves, controller setup, screen adjustment, and options are reliable and hard to misuse.

## Phase 0: Preserve And Measure The Current Emulator

Purpose: stop guessing. Build a baseline, record current behavior, and protect the existing working features.

Local preservation status: complete for build/toolchain/artifact capture in `BASELINE_MANIFEST.md`. Runtime measurement still requires a selected ROM/test ROM set and real Dreamcast hardware or a trusted emulator run.

- Document the exact build environment: KOS version, SH-ELF GCC/binutils versions, required libraries, `KOS_BASE`, `KOS_CC`, and tools like `scramble`, `mkisofs`, and `genromfs`.
- Verify current build blockers are historical or real; `sh/sa1ops.S` now assembles with DreamSDK R4, but still needs runtime compatibility testing.
- Add a known-good build mode:
  - `release-dc`: optimized Dreamcast binary.
  - `debug-dc`: symbols, less aggressive optimization, logging enabled.
  - `reference-host`: optional host-side build for correctness tests if feasible.
- Record current performance on real hardware or a trusted emulator:
  - No sound, frameskip auto.
  - Sound enabled.
  - Bilinear on/off.
  - Popular simple games, busy PPU games, and enhancement-chip games.
- Create a compatibility/performance matrix with columns for boot, input, graphics, sound, save, fps, frameskip, and notes.
- Keep existing features working: CD ROM loading, CD swapping, SRAM to VMU, settings to VMU, themes, screen adjustment, controller mapping, mouse support, layer toggles, and reset.

Exit criteria:

- Anyone can build the project from documented steps.
- Current build artifacts are measured and captured.
- Current runtime behavior is measured when ROMs and a test target are available.
- Known failing areas are listed instead of living only in memory.

Current exit state:

- Build commands are repeatable through `tools/build.ps1`.
- Build environment is repeatable through `tools/Import-DreamSdkEnv.ps1`.
- Artifact sizes and SHA-256 hashes are captured in `BASELINE_MANIFEST.md`.
- Runtime behavior remains explicitly unmeasured until ROMs and a test target are available.

## Phase 1: Accuracy Harness Before Heavy Optimization

Purpose: make performance work safe by giving every change something to prove against.

Current status: started. `BUILD_PROFILE=accuracy` now emits deterministic `SFCAST_ACCURACY` frame signatures with CPU/APU registers and memory/PPU/APU hashes. Runtime capture still needs selected test ROMs and a target.

- Define two runtime profiles:
  - `Accuracy`: closest-to-SNES behavior, minimal shortcuts, diagnostic logging available.
  - `Dreamcast Fast`: selectively optimized behavior with documented shortcuts.
- Add deterministic test hooks:
  - Reset/load ROM/run N frames/dump CPU registers, RAM hashes, PPU frame hash, APU state, and SRAM hash.
  - Optional frame capture or CRC logging from the Dreamcast build.
- Build a test ROM set:
  - 65c816 CPU opcode behavior.
  - DMA/HDMA.
  - NMI/IRQ timing.
  - WRAM/VRAM/OAM/CGRAM access timing.
  - PPU modes, mosaic, windows, color math, interlace, hires, offset-per-tile, Mode 7.
  - SPC700/APU timers, DSP echo/noise/ADSR/BRR.
- Choose a small real-game smoke suite:
  - Simple LoROM.
  - HiROM.
  - Fast action.
  - RPG with SRAM.
  - Transparency/color math heavy game.
  - Mode 7 game.
  - Mouse game.
  - At least one game each for DSP-1, SuperFX, SA-1, S-DD1, C4, OBC1, S-RTC, SPC7110, and SETA if those cores are retained.
- Track regressions in plain text first if no test framework exists.

Exit criteria:

- Core behavior changes can be compared against repeatable hashes/logs.
- Game compatibility changes are visible and attributable.

## Phase 2: Build System And Codebase Cleanup For Speed Work

Purpose: reduce friction without doing broad rewrites.

- Split build flags by file group:
  - CPU/PPU/APU hot paths get speed flags.
  - UI, file browser, XML, themes, and menus get size/stability flags.
  - Debug-only code is excluded from release.
- Revisit SH4 flags using evidence:
  - Keep proven flags only after benchmarking.
  - Re-test old experiments from `src/simple_optimization_experiments.txt`, including strict aliasing, loop unrolling, function alignment, `-mrelax`, `-m4-single-only`, and `-fomit-frame-pointer`.
  - Avoid global `-Ofast` if it breaks determinism or undefined-behavior-sensitive emulator code.
- Create small profiler counters:
  - CPU core time.
  - PPU render time.
  - APU/SPC700 time.
  - Sound mixing/output time.
  - ROM loading/decompression time.
  - VMU save time.
- Make expensive optional systems compile-time or runtime gated:
  - Netplay/server code.
  - Screenshot.
  - Cheats.
  - Theme music.
  - Zip loading.
  - Enhancement chips not needed by the current ROM.
- Replace avoidable gameplay-time allocation with startup or ROM-load allocation.
- Audit global state and hot structs for SH4-friendly layout and alignment.

Exit criteria:

- Release binary is smaller or equal while preserving features.
- Hotspot data exists before rewriting CPU, PPU, or APU code.

## Phase 3: CPU Core Accuracy And Throughput

Purpose: make the main 65c816 core both trustworthy and Dreamcast-fast.

- Establish one canonical CPU behavior layer:
  - Correct flags.
  - Correct decimal mode behavior.
  - Correct emulation/native mode transitions.
  - Correct stack wrapping and direct-page behavior.
  - Correct interrupt entry/exit timing.
- Verify the SH4 assembly CPU core against the C core or host reference.
- Keep the C core as the readability/reference fallback where practical.
- Optimize memory access:
  - Fast paths for direct ROM/RAM banks.
  - Clear slow paths for MMIO, SRAM, enhancement chips, DMA/HDMA, and open bus.
  - Reduce branchy map lookups in hot opcode paths.
- Use opcode frequency data from `src/cpu_opcode_frequencies.txt` to prioritize hot instructions.
- Tune CPU shutdown/idle detection conservatively:
  - Safe for games waiting on NMI/APU/HDMA.
  - Disabled automatically for games that break.
- Keep variable cycles accurate enough that PPU/APU synchronization does not drift.

Exit criteria:

- CPU test ROMs pass or failures are documented.
- Main CPU no longer dominates simple game frames when sound is disabled.

## Phase 4: PPU Accuracy With Dreamcast-Friendly Rendering

Purpose: make video correct first, then exploit the PVR where it actually helps.

- Define the reference renderer:
  - Correct VRAM/OAM/CGRAM behavior.
  - Correct background modes 0-7.
  - Correct sprites, priority, clipping, windows, color math, brightness, mosaic, hires/interlace, overscan, and forced blank.
- Keep scanline/event timing explicit:
  - NMI and IRQ timing.
  - H/V counters.
  - DMA/HDMA timing.
  - Mid-frame register changes.
- Profile tile conversion, sprite evaluation, line composition, color math, and final blit separately.
- Build a dirty-region/tile-cache strategy:
  - Cache decoded tiles by bit depth and palette state.
  - Invalidate only changed VRAM ranges.
  - Avoid converting entire backgrounds every frame.
- Use Dreamcast PVR carefully:
  - Hardware scaling and bilinear filtering are useful.
  - Tile/sprite composition on PVR may help only if CPU-side ordering, priority, color math, and windows remain correct.
  - Keep a software fallback for difficult PPU cases.
- Add per-game or per-scene renderer mode only if correctness remains measurable.

Exit criteria:

- Common PPU tests and visual smoke games match expected behavior.
- Frame rendering cost is predictable and low enough for sound-enabled gameplay.

## Phase 5: APU, SPC700, DSP, And AICA Sound

Purpose: turn sound from "slow and out of sync" into a core feature.

- Treat audio sync as a correctness problem, not just a mixer problem.
- Verify SPC700 opcode behavior, timers, ports, and CPU/APU communication.
- Verify DSP behavior:
  - BRR decode.
  - ADSR/gain.
  - Noise.
  - Pitch modulation.
  - Echo/FIR.
  - Key on/off and envelope edge cases.
- Introduce a stable audio clock model:
  - Emulate APU at the correct rate.
  - Resample into the Dreamcast output rate.
  - Use a small adaptive buffer to prevent crackle without large latency.
- Offload final output to AICA cleanly:
  - Keep SH4 responsible for emulation correctness.
  - Use AICA for streaming and possible lightweight mixing only when state transfer overhead is worth it.
- Add audio quality modes:
  - Accurate DSP.
  - Fast DSP with reduced echo/interpolation cost.
  - Emergency no-echo mode for very heavy games.

Exit criteria:

- Sound is enabled by default in baseline games.
- Audio remains synced over several minutes.
- Performance cost is measured and acceptable.

## Phase 6: Memory, IO, CD, Zip, And VMU Reliability

Purpose: make the emulator robust on real Dreamcast hardware.

- Define a strict memory budget:
  - Emulator core.
  - ROM image.
  - SRAM.
  - APU RAM/sample cache.
  - PPU buffers/tile cache.
  - Theme/menu assets.
  - Zip/decompression workspace.
- Stream or reject oversized ROMs gracefully instead of crashing.
- Make ROM browser validate file types and headers before loading.
- Improve CD swap flow:
  - Detect missing disc.
  - Recover if theme music stops.
  - Avoid stale file handles.
- Improve VMU behavior:
  - Let user choose VMU/device when possible.
  - Show free space and save errors.
  - Use atomic save pattern: write temp, verify, then replace.
  - Avoid gameplay hitches from auto-save by scheduling it at safe points.
- Make SRAM compatibility explicit per game.

Exit criteria:

- Bad ROM/file/disc/save states show errors instead of crashing.
- VMU saves are reliable and user-controllable.

## Phase 7: Enhancement Chips Strategy

Purpose: support enhancement chips without letting them sink baseline performance.

- Classify chips into tiers:
  - Tier 1: DSP-1 and SRAM/timing support needed by popular games.
  - Tier 2: SuperFX, SA-1, C4, S-DD1, OBC1, S-RTC, SETA.
  - Tier 3: rare or extremely expensive cases that may need compatibility warnings.
- Keep chip code dormant unless the loaded ROM uses it.
- Keep SH SA-1 assembly as the performance target, with C SA-1 fallback for correctness comparisons until runtime behavior is proven.
- Prioritize correctness first for chip detection, mapping, and save behavior.
- Optimize chip cores only after baseline LoROM/HiROM games are full speed with sound.
- Provide game-specific compatibility notes rather than hiding failures.

Exit criteria:

- Enhancement-chip games fail gracefully or run with documented status.
- Baseline emulator performance is not harmed by unused chip support.

## Phase 8: Performance Passes In Priority Order

Purpose: get speed without sacrificing the emulator's soul.

Work in this order:

1. Measure hot paths on real hardware.
2. Remove accidental overhead.
3. Improve data layout and cache behavior.
4. Specialize common safe cases.
5. Add SH4 assembly only where C cannot get close.
6. Add optional fast modes last.

Specific Dreamcast/SH4 tactics:

- Prefer small hot functions that avoid register spills.
- Avoid over-inlining large functions.
- Keep hot data local or passed in registers where possible.
- Use signed small integer types where safe because SH4 sign extension is cheaper.
- Read struct fields in forward order and write in reverse order when it helps generated code.
- Use struct copies where GCC schedules them better.
- Use `register` hints only in measured hot paths.
- Audit pointer aliasing before enabling strict/noalias flags.
- Align hot loops and functions only when benchmarked.
- Use store queues/DMA/PVR with explicit cache flush/invalidate rules.
- Keep hardware registers volatile and cache-through where required.
- Avoid floating point in emulation hot paths unless SH4 FPU gives a measured win.
- Replace expensive math in C4/SuperFX-style helpers with fixed-point or lookup-table approaches when accuracy allows.

Exit criteria:

- Performance wins are tied to benchmarks.
- Accuracy regressions are caught by tests or compatibility matrix.

## Phase 9: User Experience And Release Polish

Purpose: make the emulator pleasant and dependable, not just fast.

- Make controller mapping configurable rather than fixed by button placement.
- Keep analog/D-pad selection per player.
- Preserve Dreamcast mouse support and make hotplug limitations clear.
- Make frameskip easier to understand:
  - Auto.
  - Fixed 0-5.
  - Max auto frameskip option.
  - Per-game saved setting.
- Add clear in-game status:
  - FPS.
  - Frameskip.
  - Audio buffer health.
  - Save status.
- Keep menu/theme system lightweight:
  - No large always-loaded assets.
  - Theme music optional.
  - Fast return from menu to game.
- Package releases:
  - Plain files.
  - Self-booting image.
  - Example directory layout.
  - Compatibility list.
  - Known issues.

Exit criteria:

- A user can burn or boot a release, load ROMs, save SRAM, configure controls, and understand performance options without reading source.

## Phase 10: Release Gates

Before a public release:

- Build from clean checkout.
- Boot on target Dreamcast path.
- Run smoke ROM suite.
- Run compatibility matrix sample.
- Verify VMU save/load/settings.
- Verify CD swap and bad-file handling.
- Verify sound enabled and disabled modes.
- Verify no major memory leaks or heap growth during repeated ROM loads.
- Confirm license/readme credits remain intact for Snes9x, DreamSNES, KOS, and bundled libraries.

## Priority Stack

When goals conflict, use this order:

1. Buildability and stability.
2. Correct baseline emulation.
3. Sound sync.
4. Full-speed common games.
5. Memory footprint.
6. Enhancement-chip compatibility.
7. UI polish.
8. Optional visual/audio extras.

## What Not To Do Yet

- Do not rewrite the whole emulator before measuring.
- Do not make PVR acceleration mandatory until correctness is proven.
- Do not globally enable risky compiler flags without test coverage.
- Do not optimize enhancement chips before common games are full speed with sound.
- Do not hide accuracy shortcuts. Put them behind named performance options.
- Do not let themes, screenshots, netplay, or zip support consume memory needed by gameplay.

## First Concrete Sprint

1. Create a build setup document and fix the current assembly build path.
2. Add a performance/compatibility matrix file.
3. Add a minimal frame/perf counter log for CPU, PPU, APU, and render.
4. Pick 10 baseline games and 5 test ROMs.
5. Measure current fps with sound off and on.
6. Add an SA-1 runtime compatibility check now that `sh/sa1ops.S` builds behind `USE_SA1_ASM`.
7. Re-test compiler flags from `simple_optimization_experiments.txt` on real hardware.
8. Make sound sync the first major emulation subsystem target after build reproducibility.
