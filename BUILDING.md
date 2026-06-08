# Building Super Famicast

This project targets the Sega Dreamcast through KallistiOS (KOS) and an SH-ELF GCC toolchain. The source tree currently includes generated binaries, but active development should be done from a clean source build whenever possible.

## Required Toolchain

Install and expose these tools in your shell:

- KallistiOS with `KOS_BASE` set.
- SH-ELF GCC/binutils for Dreamcast, available through `KOS_CC`.
- KOS utilities:
  - `genromfs` through `KOS_GENROMFS`.
  - `bin2o` at `$KOS_BASE/utils/bin2o/bin2o`.
- Dreamcast binary tools:
  - `scramble`.
  - `mkisofs` for `make cdimg`.

Plain PowerShell may not have these visible on PATH:

- `KOS_BASE`
- `sh-elf-gcc`
- `make`
- `scramble`
- `mkisofs`

DreamSDK is installed at `C:\DreamSDK`. Activate it by running commands through DreamSDK's bash and sourcing `/opt/dreamsdk/environ.sh`.

For normal repo work, use the checked-in wrappers from PowerShell:

```powershell
. .\tools\Import-DreamSdkEnv.ps1
.\tools\build.ps1 -Profile release -Clean -CdImage
```

Dot-sourcing `Import-DreamSdkEnv.ps1` imports the DreamSDK/KOS variables and PATH entries into the current PowerShell session. `build.ps1` runs the build through DreamSDK bash so a fresh session does not need to remember the long command.

Manual equivalent:

```powershell
C:\DreamSDK\usr\bin\bash.exe -lc "source /opt/dreamsdk/environ.sh && cd /c/Users/allen/super-famicast/src && make BUILD_PROFILE=release"
```

You can check the current shell with:

```powershell
.\tools\check_build_env.ps1
```

Last local PowerShell check: on 2026-06-08, `tools/check_build_env.ps1` found `KOS_BASE`, `KOS_CC`, `KOS_GENROMFS`, `make`, `sh-elf-gcc`, `sh-elf-as`, `scramble`, and `mkisofs` through DreamSDK.

## Build Commands

From `src`:

```sh
make clean
make
```

Build profiles are selected with `BUILD_PROFILE`:

```sh
make BUILD_PROFILE=release
make BUILD_PROFILE=debug
make BUILD_PROFILE=profile
make BUILD_PROFILE=compat
make BUILD_PROFILE=accuracy
```

Profiles:

- `release`: fastest Dreamcast binary, current default.
- `debug`: symbols, frame pointer, easier source/debugger behavior.
- `profile`: optimized with symbols and `SFCAST_PROFILE` defined for future counters.
- `compat`: accuracy/behavior comparison profile with less aggressive flags than release.
- `accuracy`: deterministic signature logging with `SFCAST_ACCURACY` enabled.

By default the build uses the SH SA-1 CPU core for speed.

To use the portable C SA-1 fallback:

```sh
make clean
make USE_SA1_ASM=0
```

To produce `data.iso` from the `src/cd` tree:

```sh
make cdimg
```

From plain PowerShell, use DreamSDK bash:

```powershell
.\tools\build.ps1 -Profile debug -Clean
.\tools\build.ps1 -Profile release -Clean -CdImage
```

Generated outputs include:

- `src/superfamicast.elf`
- `src/bin/superfamicast.elf`
- `src/bin/raw.bin`
- `src/bin/1ST_READ.BIN`
- `src/cd/1ST_READ.BIN`
- `src/data.iso` when `make cdimg` is run

## SA-1 Build Path

`src/compile.txt` records an older failed build while assembling `src/sh/sa1ops.S`, with many `unknown opcode` and `invalid operands for opcode` errors. DreamSDK R4 now assembles and links that file successfully.

Current decision:

- Default to the SH SA-1 assembly core for performance.
- Keep the C SA-1 core in `src/sa1cpu.cpp` available through `make USE_SA1_ASM=0`.
- Treat runtime behavior as unverified until an SA-1 compatibility test is added.

Do not delete either SA-1 path. The assembly path is the performance target, and the C path is useful for correctness comparisons and toolchain fallback.

## Current Makefile Shape

The current `src/Makefile`:

- Builds `superfamicast.elf`.
- Builds successfully with DreamSDK R4 (4.0.11.2508) using KOS 2.2.1, SH-ELF GCC 13.2.0, Binutils 2.43, and GNU Make 4.4.1.
- Adds a fallback `KOS_PORTS` path of `/opt/toolchains/dc/kos-ports` because DreamSDK's active KOS wrapper may otherwise point at a non-existent `/opt/kos-ports` path.
- Passes project flags into modern KOS `CFLAGS`, `CXXFLAGS`, and `CPPFLAGS`, not only legacy `KOS_CFLAGS` and `KOS_CPPFLAGS`.
- Supports build profiles:
  - `BUILD_PROFILE=release`
  - `BUILD_PROFILE=debug`
  - `BUILD_PROFILE=profile`
  - `BUILD_PROFILE=compat`
  - `BUILD_PROFILE=accuracy`
- Compiles SH4 assembly CPU objects:
  - `sh/cpuexec.o`
  - `sh/cpuops.o`
- Uses SH SA-1 by default:
  - `sh/sa1ops.o`
- Keeps C SA-1 available with `USE_SA1_ASM=0`:
  - `sa1cpu.o`
- Can force SH SA-1 assembly explicitly:
  - `make USE_SA1_ASM=1`
  - `sh/sa1ops.o`
- Uses common Dreamcast flags:
  - `-mrelax`
  - `-m4-single-only`
  - `-fno-exceptions`
  - `-fno-strict-aliasing`
- Uses profile-specific optimization flags, with release retaining the aggressive speed settings.
- Defines emulator feature flags:
  - `_XBOX`
  - `UNZIP_SUPPORT`
  - `NOASM`
  - `SDD1_DECOMP`
  - `SPC700_C`
  - `VAR_CYCLES`
  - `CPU_SHUTDOWN`
  - `SPC700_SHUTDOWN`

The next build-system improvement should split flags by file group after a successful baseline build:

- CPU/PPU/APU hot paths.
- UI/menu/theme/file browser code.
- Optional features such as netplay, screenshots, cheats, zip loading, and theme music.

## First Successful Build Checklist

Recorded after the build environment is active:

- KOS version: 2.2.1
- SH-ELF GCC version: 13.2.0
- Binutils/as version: 2.43
- Host OS/shell: Windows PowerShell invoking `C:\DreamSDK\usr\bin\bash.exe`
- Exact debug command used: `source /opt/dreamsdk/environ.sh && cd /c/Users/allen/super-famicast/src && make clean && make BUILD_PROFILE=debug`
- Exact release command used: `source /opt/dreamsdk/environ.sh && cd /c/Users/allen/super-famicast/src && make clean && make BUILD_PROFILE=release`
- Exact profile command used: `source /opt/dreamsdk/environ.sh && cd /c/Users/allen/super-famicast/src && make clean && make BUILD_PROFILE=profile`
- Exact compat command used: `source /opt/dreamsdk/environ.sh && cd /c/Users/allen/super-famicast/src && make clean && make BUILD_PROFILE=compat`
- Exact accuracy command used: `source /opt/dreamsdk/environ.sh && cd /c/Users/allen/super-famicast/src && make clean && make BUILD_PROFILE=accuracy`
- Exact ISO command used: `source /opt/dreamsdk/environ.sh && cd /c/Users/allen/super-famicast/src && make cdimg`
- Build result: debug, release, profile, compat, accuracy, and `data.iso` builds succeeded.
- Output ELF size: `src/superfamicast.elf` is 1,115,364 bytes.
- Output raw binary size: `src/bin/raw.bin` is 1,114,632 bytes.
- Output scrambled binary size: `src/bin/1ST_READ.BIN` is 1,114,632 bytes.
- Output CD binary size: `src/cd/1ST_READ.BIN` is 1,114,632 bytes.
- Output ISO size: `src/data.iso` is 6,316,032 bytes.
- `src/sh/sa1ops.S` status: assembles and links with DreamSDK R4; default build uses SH SA-1.
- SA-1 runtime status: not tested yet.
- Real Dreamcast boot status: not tested yet.
- Emulator boot status: not tested yet.

See `BASELINE_MANIFEST.md` for the Phase 0 artifact hashes and repeatable capture command.
