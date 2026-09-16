# The Weight We Carry

An English-first H5 precision platformer about exchanging weight to change movement, resist environmental forces, and operate ancient machinery.

## Current release candidate

- Godot 4.7 project
- 24 playable rooms across four visual chapters
- Light, Balanced, and Heavy movement roles
- Weight exchange, wind, pressure gates, moving platforms, springs, and fragile floors
- Keyboard, controller, and touch support
- CrazyGames SDK v3 lifecycle integration
- Resilient local save and achievement systems

## Run locally

Open the repository with Godot 4.7.2 and run `scenes/main.tscn`.

For the exported H5 build, serve `build/web` through a local HTTP server. Opening `index.html` directly from the filesystem is not supported by WebAssembly browsers.

```powershell
cd build/web
python -m http.server 8765
```

Then visit `http://127.0.0.1:8765/`.

## CrazyGames upload

Upload `build/web/index.html` together with every sibling file in `build/web`. The build contains the CrazyGames SDK v3 bootstrap and graceful offline fallback.

## Quality gates

The QA scenes under `qa/` cover 24-room reachability, weight conservation, collision recovery, save resilience, platform mechanics, first-session guidance, CrazyGames lifecycle, and release flow.

