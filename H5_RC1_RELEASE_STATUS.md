# The Weight We Carry — H5 RC1 Release Status

Date: 2026-09-16
Candidate: 0.45.0-rc1
Source: `full-game-v49`

## Automated release gates — PASS

- 24-room reachability, including the room 23 persistent-gate/light-jump route.
- 24 checkpoint record, fall, and restore paths.
- 2,400 weight exchanges across 24 rooms with zero lost weight resources.
- 100 restore/exchange/checkpoint/pause/resume stress cycles.
- 48 static-platform landings, 26 closed-gate collisions, and 24 out-of-bounds restores.
- 21 isolated moving-platform landing and carry checks.
- Gate, spring, moving-platform, and fragile-floor runtime state coverage.
- 24 progression steps, final choice, both endings, and ending achievements.
- One animated player per room and all 24 production layouts construct successfully.
- Corrupt save payloads are rejected or sanitized.
- CrazyGames SDK v3 loader and gameplay lifecycle integration are present.
- Commercial UI, first-session tutorial, and ten animation states pass coverage.
- Main release scene launches headlessly without script/runtime failure.

## H5 artifact — PASS

- Export mode: Godot Web, compatibility renderer, threads disabled.
- Uncompressed web directory: 46,668,451 bytes.
- Upload ZIP: `release/packages/TheWeightWeCarry-0.45.0-rc1-crazygames.zip`
- ZIP size: 16,944,281 bytes.
- SHA-256: `E916F687D987A1D65EB53B5724979F83CCB14CD8D8779D50F510E6A695A59FFB`
- CrazyGames SDK v3 script is embedded in exported `index.html`.

## Manual browser gate — REQUIRED

Automated browser control was unavailable because the local Windows sandbox could not start the browser runtime. Before submission, verify the ZIP through CrazyGames Preview or a local HTTP server:

1. The game reaches its first playable frame without a blank screen or console error.
2. A/D, Space, E, R, and Escape work after clicking the canvas once.
3. Music/SFX begin only after user interaction and pause/resume correctly.
4. Browser zoom at 80%, 100%, 125%, and 150% keeps HUD and prompts readable.
5. 1280x720 and 1920x1080 show no clipped UI.
6. Touch controls appear and work on a mobile/touch device; desktop does not show duplicate controls.
7. Refresh restores progress and settings.
8. CrazyGames Preview records gameplayStart/gameplayStop without SDK exceptions.
9. Complete rooms 1 and 24, exercise one fall/recovery, and verify both ending choices.

## Submission decision

Code/content package is RC-ready. Do not submit as production until all nine manual browser checks pass and screenshots/video/store assets have received a final visual review.
