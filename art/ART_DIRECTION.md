# Production art direction — Measure Hall v1

## Visual language

- World: ancient measuring hall, graphite stone, monumental balances and suspended counterweights.
- Signature motif: aged-brass calibration ring repeated across character, platforms, vessels, gates and HUD.
- Interaction color: restrained cyan for available exchange; amber for heavy impact and irreversible choices.
- Readability: dark atmospheric background, high-value playable silhouettes, brass platform edge and regular calibration ticks.
- Character: one hooded Bearer whose torso ring visibly changes proportion between light, medium and heavy states.

## Production assets

- `production/measure-hall-background-v1.png` — 1672×941 RGB environment-only background plate.
- `production/bearer-weight-states-v1.png` — 1942×809 ARGB transparent three-state Bearer sheet.
- `visual-direction/measure-hall-target-v1.png` — visual target only; excluded from release exports.

## Generation provenance

Tool: OpenAI built-in image generation. Date: 2026-09-15.

Prompt set summary:

1. Commercial 16:9 gameplay target retaining the side-view weight-exchange mechanic while replacing beige emptiness, placeholder circles and debug HUD with graphite measuring architecture, aged brass calibration motifs, a single hooded Bearer and minimal integrated UI.
2. Environment-only background derived from the approved direction, with three depth bands, clear lower gameplay area, no characters, no text, no UI and no conflicting walkable geometry.
3. Transparent horizontal character sheet with exactly three consistent Bearer states—light, medium and heavy—using one identity, charcoal cloak and changing brass ring silhouette; no scene, labels or watermark.

All generated outputs require continued human-directed composition, runtime cropping, visual consistency review and rights/provenance tracking before release.

## Runtime implementation

- The background is repeated in viewport-width sections rather than stretched across the 3550px room.
- Each chapter applies a restrained tint while retaining the shared world language.
- Runtime platforms use graphite bodies, brass top edges and calibration ticks.
- The Bearer switches source artwork by weight and retains squash, stretch, bob, shadow and exchange-ring feedback.

## Remaining ART tasks

- ART-003: full locomotion and interaction animation frames rather than procedural transform alone.
- ART-004: dedicated production art for weight vessels, gates, wind, springs and fragile floors.
- ART-005: unique background plates and atmosphere layers for all four chapters.
- ART-006: complete custom UI theme replacing default Godot widgets.
- ART-007: rebuild HUD around ring-based weight display and responsive safe areas.
- ART-008: authored exchange, impact, checkpoint, failure and completion sequences.
