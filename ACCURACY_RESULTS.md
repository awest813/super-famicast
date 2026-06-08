# Accuracy Results

Store captured `SFCAST_ACCURACY` signatures here. Keep one row per ROM/settings/build combination and paste only the frame signatures needed to compare regressions.

## Results

| Date | ROM/Test | ROM SHA-256 | Build | Settings/Input | Frames Captured | Result | Notes |
|---|---|---|---|---|---:|---|---|
| 2026-06-08 | Harness smoke | N/A | `BUILD_PROFILE=accuracy` | Build only, no runtime ROM capture. | 0 | Build passes. | First signature harness added; runtime signatures require ROM/test target. |
| 2026-06-08 | Donkey Kong Country (USA) test disc | `628147468C3539283197F58F03B94DF49758A332831857481EA9CC31645F0527` | `BUILD_PROFILE=accuracy` + CD image | Local ROM copied to ignored `src/cd/roms`; Flycast process already running. | 0 | Disc prepared. | `src/data.iso` SHA-256 `EDF36E36688590A1D65EC99A834217B339CC83193B1479BF6F24D5AD181855BE`; runtime signatures still need capture from emulator output. |

## Signature Blocks

Add captured log snippets below this line.
