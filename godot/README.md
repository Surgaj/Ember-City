# EMBER INN — Godot Rebuild

Branch: `godot-rebuild`

## Milestone 0.1 — Building Structure

This milestone intentionally contains **only the inn architecture**.

Implemented:

- true 3D Godot scene with an orthographic isometric camera;
- mobile-friendly OpenGL compatibility renderer;
- foundation and wooden interior floor;
- back and left exterior walls using real openings for windows;
- cutaway layout so the interior remains readable from the camera;
- bedroom partition with a real doorway gap;
- café partition kept visually connected to the lobby;
- future expansion wing with an architectural doorway;
- timber beams, posts and entrance frame;
- basic soft lighting and real engine shadows;
- responsive camera framing for portrait/mobile screens.

Intentionally not implemented yet:

- surroundings / landscaping;
- furniture;
- reception desk;
- Ember;
- guests or staff;
- navigation/pathfinding;
- economy or upgrades;
- UI.

## Floor plan intent

The current structure establishes the future visual flow:

`front entrance → lobby/reception → Ember core → room / café → future wing`

The next milestone should work on the **surroundings and exterior footprint only**, without adding gameplay yet.


## Web preview

Every push to `godot-rebuild` is exported automatically with Godot 4.7.2 and published inside the existing GitHub Pages site at:

`https://surgaj.github.io/Ember-City/godot-preview/`

The preview is intentionally separate from the legacy web game on the repository root.
