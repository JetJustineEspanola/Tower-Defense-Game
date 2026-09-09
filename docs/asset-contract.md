# Placeholder and 3D asset contract

Jet owns final 3D art. Primitive meshes unblock programming. Preserve futuristic fantasy chibi proportions: a large readable head/core, compact body, short limbs, and an unmistakable role silhouette. Use dark neutral bases with saturated role colors and small luminous accents. Avoid fine surface detail that disappears in the fixed isometric view.

| Responsibility / identity | Scene | Placeholder silhouette and palette |
| --- | --- | --- |
| Jet / attack tower | `scenes/towers/pulse_spire.tscn` | Blue-purple compact spire, large orb, short barrel |
| Ronel / objective bug | `scenes/troops/core_runner.tscn` | Cyan-blue crystalline head and low six-legged bug |
| Arjie / defender tower | `scenes/towers/sentinel_gate.tscn` | Green-teal guardian tower; visual only |
| Matthew / attack bug | `scenes/troops/breach_beetle.tscn` | Orange armored body, mechanical legs; visual only |
| Canguit / economy bug | `scenes/troops/cache_mite.tscn` | Gold-green pack body; visual only |
| Core / portal | `scenes/maps/code_core.tscn`, `attacker_portal.tscn` | Purple core on plinth / cyan upright ring |

Required release inventory also includes Mana Mint, Sentinel guard, modular floor/route kit, deployment marker, selection ring, attack impact, damage pulse, training completion, and result effects. The slice contains only Pulse Spire and Core Runner gameplay. The other named wrappers preserve responsibilities without implying completed mechanics.

## Import interface

- Format: GLB/glTF 2.0 for runtime; retain editable `.blend` source in the art delivery package. PNG textures, base color/normal/ORM where justified. Use `assets/models/<archetype>/<archetype>.glb`; import through Godot 4.6, never edit `.godot/imported`.
- Axes: +Y up; -Z forward. One Godot unit = one meter. Root transform identity, scale (1,1,1). Apply modeling transforms before export.
- Origin/pivot: ground center at (0,0,0). Lowest feet/plinth contact is Y=0; no hidden compensating wrapper scale or negative foot offset.
- Footprints: towers about 3×3 m and 4 m tall; Core Runner about 3×2.5 m and 2.3 m tall; core 5×5 m and 6 m tall; portal 5 m wide/tall. Keep all deployment views within their 4.4 m marker diameter.
- Selection: tower ring radius 2.2 m; troop ring radius 1.5 m. Ground selection uses the authored node and a 2.5 m hit radius; visuals do not authorize placement.
- Sockets: `AttackSocket` (muzzle, toward -Z), `HealthBarSocket` (above silhouette), `VFXSocket` (body/core). Export stable names and attach semantic markers under Visual. Health bars can move artistically without changing simulation.
- Team color: material slot `TeamColor` (index 0 in final imported mesh); keep the dark structural slot separate. Placeholder `team_color` export is the current adapter. Tint accent regions rather than the whole model.
- Animation names: `Idle`, `Move`, `Attack`, `Hit`, `Death`, `Spawn`. Loop Idle/Move; one-shot the rest. Root stays fixed; movement comes from route progress, not root motion. Static procedural meshes substitute for all clips in this graybox. Cosmetic facing and position smoothing live in BattlefieldView.
- Collision: host combat uses logical distances and route progress. Optional final selection collision is a capsule (troop radius 1, height 2) or box (tower 3×4×3). It must not participate in route blocking, push units, or decide damage.
- Replace only the wrapper's `Visual` child. Preserve wrapper path, stable archetype ID, origin, and event boundary. No scripts that purchase, attack, award gold, or instantiate network entities belong in an imported asset.

Initial budgets to validate on target PCs: 5k triangles per unit/tower, 2 materials per ordinary asset, 1024² atlas per archetype, one 2048² environment atlas. These are working art limits, not measured performance claims. Keep licenses/attribution with every external asset. All current placeholder geometry is generated locally and includes no third-party art.

Acceptance: import without corrective scale/pivot transforms; inspect at both requested resolutions and zoom limits; check foot contact, forward facing, material tint, socket names, and silhouettes. Physical-PC visual/performance review and a final authored GLB sample still require the art/reviewer handoff.
