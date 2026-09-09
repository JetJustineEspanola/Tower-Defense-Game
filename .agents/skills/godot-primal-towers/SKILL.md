---
name: godot-primal-towers
description: Implement, debug, and review Primal Towers Godot 4 features involving GDScript, scenes, 3D imports, grid combat, economy, and LAN replication. Use for this project's development and verification, not unrelated games or standalone artwork.
---

# Godot Primal Towers

Deliver small, verifiable changes to a semester-scale 1v1 tower-defense game. Treat these as engineering defaults, not a certification or universal industry standard. Apply only sections relevant to the current task.

## Establish the task

1. Read applicable AGENTS.md files, project.godot, relevant documentation, and existing implementation. Inspect the working-tree diff; preserve unrelated changes.
2. Determine the exact Godot version, executable, renderer, target platforms, and test commands. Consult version-matched documentation; do not upgrade the engine or add dependencies without authorization.
3. Identify the outcome, affected interfaces, acceptance criteria, and verification method. Plan cross-system changes first. For diagnosis or review, report findings without implementing changes unless requested.
4. Implement the smallest coherent slice using existing conventions. Avoid whole-project rewrites and unrelated formatting.

## Preserve design decisions

- Respect confirmed attacker/defender rules, limited tower and unit types, upgrades, ten waves, gold economy, and LAN requirements.
- Clarify consequential ambiguities before encoding them: leak threshold, wave-end timing, and how passive income interacts with zero-gold defeat. Do not silently substitute a preferred rule.
- Preserve tower damage and economy speedup mechanics when required. Propose scope cuts separately.
- Distinguish Wi-Fi hotspot LAN from Bluetooth transport. Treat ENet over Wi-Fi as a proposed implementation, not evidence of Bluetooth support; confirm platform feasibility.

## Code and scene architecture

- Use typed GDScript for public interfaces, exported properties, signals, and important state. Follow existing formatting or Godot's GDScript style guide. Explain intentional dynamic typing.
- Prefer cohesive scenes and composition over deep inheritance. Keep feature assets near their scenes where compatible with the existing layout.
- Separate simulation, presentation, and network transport. UI requests actions and displays state; it must not independently award gold or calculate authoritative damage.
- Use custom Resource definitions for configuration. Treat shared definitions as immutable; keep per-instance health, cooldowns, and upgrade state separate.
- Use autoloads only for application-wide services. Make match state explicitly owned and resettable.
- Prefer explicit dependencies and typed signals to fragile deep node paths and repeated global searches.
- Preserve resource IDs, node ownership, signals, and animation track targets when editing scenes.
- Clean up temporary nodes, timers, and subscriptions at their ownership boundary. Revalidate references after await when nodes may have been freed.
- Reject invalid external input clearly. Do not mask broken required dependencies with silent null guards or blanket warning suppression.

## Grid, combat, and economy

- Store logical grid occupancy independently of meshes, for example using Vector2i coordinates. Derive visuals from that state.
- Validate bounds, occupancy, terrain, path rules, and affordability before committing placement. Invalid purchases must neither charge gold nor partially alter state.
- Use stable entity IDs and explicit lifecycle states. Resolve each unit as killed or leaked exactly once; award rewards once.
- Use integer currency and documented rounding rules. Keep damage, armor, income, and upgrade calculations testable without rendering.
- Keep simulation timing independent of render frame rate. Use an appropriate fixed simulation tick and elapsed-time calculations.
- Use waypoints or path progress for fixed-path units. Add dynamic navigation only when gameplay requires it.
- Define targeting priorities and tie-breaking explicitly.
- Bound economy bonuses using validated cooldowns and reward limits. Treat client-reported puzzle completion as untrusted; define what the host can actually validate.

## LAN authority and replication

- For host-authoritative play, let the host decide gold, purchases, spawning, damage, deaths, leaks, waves, and victory.
- Route the host player's own actions through the same validation service as client requests.
- Accept intentions, not claimed results. Validate sender identity from the networking API, assigned role, match phase, payload types, allowlisted IDs, ranges, cooldowns, and affordability.
- Expose client-callable RPCs only when necessary. An any_peer RPC does not authorize its caller.
- Keep object decoding disabled for untrusted network data. Reject arbitrary resource paths and executable payloads.
- Use match-scoped request IDs or equivalent replay protection for transactions. Make duplicates idempotent and reject stale requests.
- Choose transfer modes and channels deliberately: reliable delivery for transactions and lifecycle events; bounded-frequency snapshots with interpolation where suitable for movement.
- Use MultiplayerSpawner and MultiplayerSynchronizer where they fit, with explicit authority. Verify matching RPC signatures and node paths across peers. Prevent duplicate host-side execution.
- Include protocol/content compatibility checks and scene-ready coordination.
- Define disconnect behavior. Reject unsupported late joins clearly; do not introduce reconnect or host migration without scope approval.
- Reset peer references, entity registries, pending requests, and match state on exit or rematch.
- Recognize that host authority does not protect against a malicious host.

## 3D assets and performance

- Preserve editable source assets. Prefer GLB/glTF for delivery when compatible with the project; record external asset licenses and attribution.
- Validate scale, axes, pivots, normals, UVs, materials, skeleton compatibility, animations, and collision dimensions after import.
- Avoid compensating transforms that hide inconsistent source scale.
- Add gameplay using wrapper/inherited scenes or supported import overrides. Never hand-edit generated import caches or binary models as text.
- Separate visual meshes from logical state. Prefer simple collision shapes where sufficient.
- Set texture, material, shadow, animation, and geometry budgets from target-device measurements, not arbitrary universal limits.
- Profile a representative worst-case wave. Report frame time, entity count, memory, and draw calls when relevant.
- Optimize measured bottlenecks first. Use pooling, spatial indexing, reduced targeting frequency, or MultiMesh only when the tradeoffs justify their complexity.

## Verification and delivery

1. Reproduce bugs where feasible and add focused regression tests. Reuse existing test infrastructure; do not install a framework silently.
2. Run documented import and parse checks. If missing, inspect the installed executable's --help and select supported headless checks. An editor import pass is not a complete runtime test.
3. Test relevant invariants: placement rejection, insufficient funds, upgrade caps, armor boundaries, death-versus-leak ordering, reward uniqueness, wave completion, and rematch reset.
4. For networking changes, use two local processes when available. Verify both host/client role arrangements, duplicate and invalid requests, and disconnects. Reserve hotspot/firewall/device claims for actual two-device tests.
5. For visual changes, inspect the rendered game or request screenshots/manual confirmation. Check camera framing, model scale, materials, animation, placement previews, UI scaling, and input.
6. Review the final diff and run available format/lint checks. Keep source assets, import settings, and required UID sidecars version-controlled; exclude generated .godot caches and secrets. Do not migrate asset history to LFS or publish changes without authorization.
7. Report what changed, checks actually run, outcomes, and unverified behavior. Distinguish pre-existing failures from regressions. Never claim visual or multiplayer correctness solely from headless success.

## Authoritative references

Consult relevant pages only. Select the project's exact version rather than assuming stable matches the installation.

- Best practices: https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html
- GDScript style: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- Multiplayer: https://docs.godotengine.org/en/stable/tutorials/networking/high_level_multiplayer.html
- 3D imports: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/index.html
- CLI: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
