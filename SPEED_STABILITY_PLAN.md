# Speed And Stability Plan

Focused execution plan for making Super Famicast faster and harder to crash,
building on the phased roadmap in [SUPER_PLAN.md](SUPER_PLAN.md). Each item is
small, independently testable, and ordered by risk: inspection-verifiable fixes
first, hardware-measured experiments second, structural rewrites last.

Ground rules:

- Every speed change must be measurable against `PERFORMANCE_BASELINE.md`
  (profile build prints per-second `SFCAST_PROFILE` timings) and must not
  regress the `BUILD_PROFILE=accuracy` frame signatures.
- Every stability change must fail loudly (log + clean exit) rather than
  silently corrupt state or hang the console.
- Default behavior never changes without a hardware measurement; risky
  experiments hide behind build knobs.

## Speed Track

### S1. Cheaper frame pacing in `S9xSyncSpeed` — DONE

`src/main.cpp` called `gettimeofday()` 2-3 times per frame (and in a tight
catch-up loop) plus `timeval` carry math in the hottest scheduling path.
Replaced with KOS `timer_us_gettime64()`: one fast 64-bit microsecond read,
plain integer compares, identical skip/render decisions.

### S2. Strict-aliasing build knob — DONE

`src/simple_optimization_experiments.txt` records the single best measured
win (22 → 24 FPS) from dropping `-fno-strict-aliasing`, and the known
strict-aliasing violations were already fixed in commit 851cd7b. The Makefile
now accepts `USE_STRICT_ALIASING=1` to drop the flag for A/B testing on
hardware. Default stays `0` (unchanged behavior) until a hardware pass
confirms no regressions, then flip the default.

### S3. Asynchronous texture upload — KNOB ADDED, needs hardware

`display_snes_screen()` does a synchronous `sq_cpy` of the full frame
(~115 KB) then blocks in `pvr_wait_ready()`. The DMA alternative
(`pvr_txr_load_dma` + scene submit from the completion callback, with the
required data-cache flush) is now compiled in with `USE_TEXTURE_DMA=1`.
DMA frees the SH-4 during the copy; the callback path must be validated on
real hardware before this can become the default. Default build unchanged.

### S4. Sound sync and mixing cost

README documents sound as "not synced or fast". Next steps, in order:

1. ~~Profile the sound path with an `SFCAST_PROFILE` counter.~~ DONE:
   `S9xGenerateSound()` (poll + mix + SPU transfer) is now timed and
   reported as `sound_us=` in the per-second profile line. The profile
   clock also switched from `gettimeofday` to `timer_us_gettime64()` to
   cut measurement overhead.
2. Audit `sfcastGetSound` → `scherzo_snd_stream_poll` for redundant copies;
   samples currently pass through mix buffer → separation buffers → SPU DMA.
3. Tie sample generation to emulated frame time instead of poll-time
   back-pressure to fix drift (this is the "not synced" part).

### S5. PPU/tile hot paths (after profiling data)

Largest remaining CPU cost is tile rendering (`tile.cpp`, `gfx.cpp`).
Do not touch until S4's profiling counters confirm where frame time goes
on hardware; then optimize the top offender with the accuracy harness as
the safety net (per SUPER_PLAN Phase 1).

## Stability Track

### T1. OOM crash in `CMemory::Init` — DONE

`memset(BSRAM, 0, 0x80000)` ran before the allocation null-check in
`src/memmap.cpp`; a failed allocation crashed instead of returning FALSE.
Memset moved after the check.

### T2. Unchecked allocations in the sound stream — DONE

`src/scherzo_snd_stream.cpp` never checked `malloc` in `filter_add`, the
stereo separation buffers, or `snd_mem_malloc` (SPU RAM). Failures now log
and bail out of init instead of writing through null pointers / SPU offset 0.

### T3. File browser path overflows — DONE

`src/dc_file_browser.cpp` grew `m_dir` with unbounded `strcpy`/`strcat`
from directory names on the inserted CD. Deeply nested or hostile disc
layouts could overflow the 4 KB buffers. All path writes are now bounded;
an over-long path is refused rather than truncated mid-write.

### T4. Unchecked PVR memory allocation — DONE

`texture_init()` in `src/main.cpp` ignored `pvr_mem_malloc` failures and
would later DMA into a null VRAM pointer. Now fails loudly via the same
printf + exit path the screen-buffer allocation uses.

### T5. Infinite hang in `dc_sound_init` — DONE

`src/dc_sound.cpp` spun forever waiting for the AICA firmware handshake.
If the firmware upload fails, the console hard-hangs with no diagnostics.
Both waits now time out (~2 s), log, and continue without sound instead of
hanging.

### T6. Run-loop hardening

- Auto-save SRAM pause — MITIGATED: periodic auto-saves now CRC the SRAM
  image and skip the slow whole-file VMU write when the content already
  matches what was last written to the same save path. RTC games
  (S-RTC/SPC7110) always write, because the save itself folds time data
  into the image. Explicit menu saves always write. Known limitation: the
  skip cannot detect a VMU swapped for another in the same port; use the
  menu save after swapping cards. Remaining idea if
  pauses persist for games that churn SRAM: chunked/incremental VMU
  writes spread across frames.
- ROM header-derived size audit — DONE for the cases found:
  - Multi-part zip loading (`loadzip.cpp`) only bounded the first part;
    later parts could overflow the ROM buffer by megabytes. Every part is
    now checked against the remaining buffer and fails cleanly.
  - `SRAMSize` header bytes above 7 fed `1 << (SRAMSize + 3)` shifts into
    undefined behavior; clamped at both parse sites (7 already means the
    full 128 KB buffer, so in-range behavior is unchanged).
  - The checksum warning at `InitROM` evaluated `1 << (ROMSize - 7)` with
    untrusted `ROMSize` (negative shift / signed overflow); now guarded.
  - Note: zipped slot-1/slot-2 multi-cart ROMs extract to the ROM base
    rather than the slot offset (`FileLoader` ZIP path ignores its buffer
    argument) — pre-existing functional limitation, not a crash; load
    Sufami Turbo slot carts unzipped.

## Verification

- No SH-ELF toolchain exists in this environment; changes in this pass are
  conservative, inspection-verified, and keep default build flags identical.
- Before the next release pass, on a DreamSDK machine:
  1. `make BUILD_PROFILE=profile` and capture `SFCAST_PROFILE` lines into
     `PERFORMANCE_BASELINE.md` for the standard ROM set (before/after S1).
  2. Build with `USE_STRICT_ALIASING=1`, run the compatibility smoke set,
     and record FPS deltas in the flag experiment log.
  3. `make BUILD_PROFILE=accuracy` and diff `SFCAST_ACCURACY` signatures
     against the previous build to prove no behavior change.
