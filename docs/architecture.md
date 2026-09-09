# CodeBorn architecture

CodeBorn 0.1.0 targets Godot 4.6 stable (`89cea1439`), typed GDScript, Windows x86_64, and the Compatibility renderer. The shared foundation runs one Pulse Spire and one Core Runner archetype on Arcane Crossing. It is the M0/M1 implementation baseline; milestone acceptance still requires reviewer agreement and physical LAN evidence.

## Ownership boundaries

| Area | Entry points | Contributor can change independently |
| --- | --- | --- |
| Networking | `scripts/network/network_manager.gd`, `discovery.gd` | ENet lifecycle, protocol, readiness, discovery, transport reliability |
| Gameplay | `scripts/combat/battle_simulation.gd`, `scripts/economy/wallet.gd` | Fixed-tick rules and transactional validation |
| UI | `scenes/ui`, `scenes/lobby`, `battle_screen.gd`, `UI`, `CodeBornScreen` | Screen composition and input feedback; no wallet or combat mutation |
| Questions and QA | `QuestionRepository`, `resources/data/questions.json`, `tests` | Reviewed content, validator, authoring interface, regression scenarios |
| Art | `assets/placeholders`, `scenes/towers`, `scenes/troops`, `scenes/maps` | Replace the `Visual` child, preserve wrapper origins and sockets |

Autoloads are application services. AppState holds build identity and notices; SceneRouter owns screen routing; SettingsManager persists local preferences; AudioManager exposes Music and Effects buses; QuestionRepository validates and reads local packs; NetworkManager owns the session; MatchState owns a resettable BattleSimulation only on the host and a presentation snapshot on both peers. No imported visual runs combat logic.

`BattleSimulation` is a RefCounted rules object, independent of rendering and transport. Its `command(peer, match_id, sequence, action, payload)` returns an acknowledgment string, and `step(delta)` advances the world. `snapshot_for(peer)` removes the other player's private data. UI calls `MatchState.request()` and observes `updated` and `command_result`. NetworkManager exposes `lobby_changed`, `status_changed`, and `reveal_changed`.

The scene list is centralized in SceneRouter. The same autoload paths exist on both peers throughout navigation, so RPC paths survive scene changes. A fresh simulation is constructed for every rematch and released on menu exit. Scenes connect owned methods to persistent services; avoid lambdas that capture only child controls, because those closures can survive their screen.

## Data contracts

`resources/data/catalog.json` is immutable balance/content data. `map.json` owns the route and stable deployment IDs, and `questions.json` is the bundled pack. Dictionary fields are dynamically shaped at these JSON/network boundaries; public functions and important local variables have explicit GDScript types. Do not replace a dictionary field's type without updating protocol compatibility and tests.

Match records contain match_id, tick, phase, phase_left, remaining, elapsed, attacker, defender, base_hp, wallets, towers, troops, orders, blueprint_abilities, questions, and outcome. Peer IDs are integers; the host is always peer 1 and can have either role. Nodes use zero-based authored indices (displayed as 01–12). Entity/order IDs increase monotonically within a match. Commands use a monotonically increasing per-peer sequence and a match ID.

Tower dictionaries are keyed by node ID and contain stable entity ID, HP, abilities, normalized cooldown, last shot count, and target ID. Troops are keyed by entity ID and contain HP, route distance, frozen speed/contact damage/abilities, slow expiry, and cosmetic formation offset. Orders freeze the purchased stats and ability IDs. Snapshot dictionaries are copied; presentation must not write back into the simulation.

## Work ordering

Networking can improve the snapshot transport without changing commands. Gameplay can add archetypes behind the catalog and command boundary. UI can replace programmatic layouts with authored scene children while retaining service calls. Question contributors can replace the three-question prototype with reviewed records using the documented schema. Jet can replace placeholder Visual children without changing any purchase, movement, or damage code.

Before merging any shared-interface change, update `docs/network.md`, tests, and content/protocol version as appropriate. Current later-milestone exclusions are recorded in `known-limitations.md`.
