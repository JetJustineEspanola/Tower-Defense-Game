# LAN implementation stage

Read when actual networking or multiplayer correctness is assigned. Do not impose this architecture on the first offline UI, map, question, or combat prototype.

## Connection and lobby

- Recommended transport: Godot high-level multiplayer with ENet over the shared Wi-Fi/hotspot network. Discovery is a separate function from ENet joining; plan a local discovery mechanism when requested and retain direct-IP joining as a useful fallback.
- Let the host own authoritative match state. Keep transport separate from the controllers already used by local gameplay.
- Use real peer data to replace fake lobby/player data. Limit the game to two players and define full-lobby, incompatible-version, host-leaves, and join-failure responses.
- Require both players to be ready before the host starts. Choose first-match roles on the host, synchronize the five-second reveal, and coordinate scene readiness before gameplay begins.

## Authority and correctness

- The host decides balances, purchases, placement, training completion/spawn, damage, deaths, arrivals, question costs/rewards, upgrades, match time, and results. Host-player actions go through the same checks as client intentions.
- Validate the actual RPC sender, assigned role, phase, allowlisted entity/question IDs, values, costs, and cooldowns. Accept requested actions rather than client claims such as "I earned 100 gold" or "this enemy died."
- Expose only needed client-callable RPCs. Keep untrusted object decoding disabled and reject arbitrary resource paths or executable payloads.
- Resolve purchases, answers, and lifecycle events idempotently using match-scoped IDs or an equivalent mechanism. Prevent duplicate transactions and stale requests from previous matches.
- The host tracks the assigned question, submission state, and reward. It checks answers itself. Do not promise that LAN authority can stop a player inspecting question data or a malicious host cheating.
- Use reliable delivery for transactions and lifecycle events; choose movement snapshots/interpolation and update frequency according to actual needs. Use MultiplayerSpawner/MultiplayerSynchronizer where they simplify explicit authority.
- Keep RPC signatures/node paths compatible across peers and prevent duplicate host execution. Match protocol/content versions and establish readiness before sending gameplay state.
- On leaving or rematching, reset timers, entities, question state, balances, pending requests, peer references as applicable, and previous match IDs. Swap the previous roles on a rematch.
- Agree on disconnect outcomes before implementing them. Do not silently add reconnection or host migration.

## Verification

- Run two local processes for initial host/client checks when available. Exercise both role arrangements, invalid/duplicate requests, training completion, question reward uniqueness, result agreement, and rematch reset as relevant.
- Use two actual Windows devices on the intended network to substantiate Wi-Fi/hotspot discovery and connectivity claims. Same-machine success is insufficient evidence for firewall or device-to-device behavior.
- For performance, measure representative peak concurrent troop counts and effects. There are no waves; avoid benchmarks or game logic that assume wave boundaries.

Reference: [Godot 4.6 high-level multiplayer](https://docs.godotengine.org/en/4.6/tutorials/networking/high_level_multiplayer.html).
