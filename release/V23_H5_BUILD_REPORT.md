# v23 H5 candidate build report

Version: `0.43.0-alpha`

## Character performance pass

- Added a deterministic ten-pose animation state machine.
- Locomotion distinguishes idle, walk, takeoff, rise, fall and landing.
- Gameplay events directly trigger exchange, heavy impact, failure and victory performances.
- Weight-dependent silhouettes remain intact in every state.
- Directional facing, stride, anticipation, recoil, squash, stretch, ring motion and shadow response are authored per pose.

## Automated evidence

- Ten-state animation coverage test: pass.
- 24-room animated-player construction regression: pass.
- CrazyGames SDK/compliance regression: pass.
- Web export: pass, 9 files, 46,654,242 bytes (44.49 MiB).

## Release judgment

The runtime animation system is complete. ART-003 remains partially open until the visual-quality gate decides whether the procedural pose treatment is strong enough or requires dedicated sprite frames. ART-005 and ART-008 remain primary release blockers.
