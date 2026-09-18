# EMBER INN — Godot Rebuild

Branch: `godot-rebuild`

## Milestone 0.6 — Readable Check-in + Camera Pan

This milestone makes the first service interaction readable and adds direct camera navigation for mobile/desktop.

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
- simple rugs that reinforce the arrival-to-lobby flow;
- an open bedroom door so the room reads as a private space;
- a `NavigationRegion3D` with a deterministic test navmesh;
- one temporary `CharacterBody3D` guest using `NavigationAgent3D`;
- the guest loops through entrance → reception → lobby → room → sleep → reception → exit;
- a physical coin is added to the reception after each completed stay;
- a headless navigation smoke test runs before every Web export;
- the guest now follows a narrow safe navigation ribbon instead of cutting through props;
- one receptionist stands behind the counter with an idle/service reaction;
- check-in and payment emit visible receptionist reactions;
- the Ember flame now animates continuously with moving flame layers and rising sparks;
- the receptionist visibly hands a physical key to the guest;
- guest turning is smoothed instead of snapping;
- payment launches visible light pulses toward the Ember;
- the Ember reacts by briefly growing and brightening;
- flame emission was reduced so orange/red shape remains visible;
- the isometric camera can now be dragged/panned with touch or left mouse drag, with clamped bounds.

Intentionally not implemented yet:

- guests or staff;
- navigation/pathfinding;
- economy or upgrades;
- UI.

## Floor plan intent

The current structure establishes the future visual flow:

`front entrance → lobby/reception → Ember core → room / café → future wing`

The next milestone should validate the 0.6 interaction visually, then refine **reception framing / bell feedback only** if needed before adding a second guest.


## Web preview

Every push to `godot-rebuild` is exported automatically with Godot 4.7.2 and published inside the existing GitHub Pages site at:

`https://surgaj.github.io/Ember-City/godot-preview/`

The preview is intentionally separate from the legacy web game on the repository root.
