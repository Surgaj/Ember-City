# EMBER INN — Godot Rebuild

Branch: `godot-rebuild`

## Milestone 0.3 — Interior Identity

This milestone keeps the architecture and surroundings, and adds the **first readable interior stations**.

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
- responsive camera framing for portrait/mobile screens;
- terrain base surrounding the building;
- a clear entrance path aligned with the front doorway;
- grass variation, rocks, bushes and perimeter trees;
- an intentionally empty clearing reserved for the future expansion wing;
- a central Ember hearth with a real `OmniLight3D` warm light;
- subtle Ember light flicker;
- a reception blockout with desk, register, bell and key rack;
- one recognizable bedroom setup with bed, mattress, pillow and side table;
- a café blockout with counter, coffee machine, pastry case and stools;
- simple rugs that reinforce the arrival-to-lobby flow.

Intentionally not implemented yet:

- guests or staff;
- navigation/pathfinding;
- economy or upgrades;
- UI.

## Floor plan intent

The current structure establishes the future visual flow:

`front entrance → lobby/reception → Ember core → room / café → future wing`

The next milestone should add **one temporary test guest only** and validate navigation: entrance → reception → Ember. No economy, no hotel loop, no multiple NPCs yet.


## Web preview

Every push to `godot-rebuild` is exported automatically with Godot 4.7.2 and published inside the existing GitHub Pages site at:

`https://surgaj.github.io/Ember-City/godot-preview/`

The preview is intentionally separate from the legacy web game on the repository root.
