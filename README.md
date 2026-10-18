# SHADOWS OF THE LOST WORLD

## Playable browser alpha — no Godot
The browser game is in [index.html](./index.html). It uses Three.js from a pinned CDN and runs in a modern browser; no engine installation or APK is required.

### Controls
- Desktop: WASD / arrow keys to move; E to interact.
- Mobile: on-screen directional pad and INTERACT button.
- Find three glowing shards, gather wood and stone, manage hunger/health, and craft one campfire using 5 wood + 3 stone.

### Verification
- GitHub Actions browser test run [39151965144](https://github.com/paz7azaab-lab/shadows-of-the-lost-world/actions/runs/39151965144) passed all five browser tests: canvas/HUD startup, campfire crafting state, shard objective completion, keyboard movement, and phone-sized layout.
- This verifies the browser build on GitHub's headless Chromium runner, not a physical phone.
- GitHub Pages deployment is not yet published: GitHub rejected the workflow's attempt to create a Pages site because the connected integration lacks that repository-settings permission. After Pages is enabled in repository Settings, the deployment workflow can be manually run from Actions.

### Current scope
This is an early playable alpha, not the finished game. The forest, ruins and character use simple procedural 3D meshes. Multiplayer, saving, enemies/combat, final art and an Android APK are not implemented. The previous Godot source files remain in the repository but are not needed for this browser alpha.
