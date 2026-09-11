# Team plan snapshot

Based on the user's planning conversation through 2026-09-11. These describe known responsibilities and approved intent, not live issue status or evidence that code is finished. Refresh GitHub and inspect the repository when the current task depends on either.

Repository: https://github.com/JetJustineEspanola/Tower-Defense-Game

Board: https://github.com/users/JetJustineEspanola/projects/1

## Ownership and milestones

| Member | Responsibility | Initial milestone | Handoff |
| --- | --- | --- | --- |
| Jet / user | 3D art and main map | `main_map_layout.tscn` with ground, visible route, base position, camera/light, spawn/base markers, and tower nodes | Share model scale, path direction, and node locations with Canguit and Ronel |
| Arjie | Resources and Astral Questions | Gold/mana display, valid spending, passive mana regeneration, one usable question and one-time reward | Provide resource methods/signals and a reusable panel |
| Ronel | Tower and bug combat | One tower detects a target in range, attacks on a cooldown, and damages a bug | Agree on damage method and detection layers with Canguit |
| Canguit | Enemy movement and later upgrades | One bug follows a fixed path and resolves arrival once | Supply a damageable bug scene and arrival signal; later upgrade work is separate |
| Matthew | UI and screen flow | Starting Screen followed by offline LAN Lobby and Game Lobby UI | Expose UI intentions and state updates for future networking integration |

Issue links from the conversation:

- Arjie: [#43](https://github.com/JetJustineEspanola/Tower-Defense-Game/issues/43), `[Arjie] Resources and Arcane Question Prototype`. The user subsequently asked to reduce demos/testing and focus on the Astral Question. Inspect the latest body rather than restoring the original practice exercise.
- Ronel: [#44](https://github.com/JetJustineEspanola/Tower-Defense-Game/issues/44), `[Ronel] Tower Range and Damage Prototype`.
- Canguit: [#45](https://github.com/JetJustineEspanola/Tower-Defense-Game/issues/45), `[Canguit] Bug Path Movement Prototype`.
- Matthew: [#48](https://github.com/JetJustineEspanola/Tower-Defense-Game/issues/48), `[Matthew] LAN Lobby and Game Lobby UI Prototype`, following starting-screen task [#42](https://github.com/JetJustineEspanola/Tower-Defense-Game/issues/42).

## Matthew's approved next task

Allow 3-4 beginner development days. Use fake lobby/player data; no real discovery, hosting, joining, or multiplayer synchronization is implied.

- Day 1: Play opens LAN Lobby. Add player name, Host, Refresh, Direct IP, Join, Back, reusable lobby cards, and one selected lobby. Show sample lobby names, host, player count, and version.
- Day 2: Validate required fields; show Searching/Joining feedback; prevent repeated clicks; support Back. Fake Direct IP input does not establish a network connection.
- Day 3: Build Game Lobby with two reusable player slots, host badge, Ready state, host-only Start, and Leave. Start is enabled only when both fake players are ready. If no gameplay scene is ready, use an explicit local start signal/status rather than claiming a match started.
- Day 4 if needed: Improve hover/focus/disabled states, long-name handling, and layout at 1366x768 and 1920x1080; fix errors.

Expected reusable scenes: `lan_lobby_screen.tscn`, `lobby_card.tscn`, `game_lobby_screen.tscn`, and `player_slot.tscn`. Use the repository's actual folder layout.

## Coordination defaults

- Everyone can begin independently. Art is not a blocker: use basic shapes in the reusable visual slots until models arrive.
- Ronel can begin with a stationary damageable target while Canguit builds movement. Replace it with the shared bug when ready.
- Jet owns the map layout. Canguit is a proposed coordinator for the first combined gameplay scene, subject to the team's agreement; the earlier meeting suggestion is not a confirmed assignment.
- Start integration after the individual behaviors run: map + bug path, then tower combat, then resources/question panel. Connect lobby Start to the local gameplay scene when that connection is assigned.
- Suggested shared names are `enemies`, `towers`, `tower_nodes`, `EnemyPath`, `AttackerSpawn`, and `DefenderBaseTarget`. Agree on them or reuse existing names; they are not proof these groups/nodes exist.
- A weekly demo should show each member's assigned behavior and one useful integration step. Do not promise the entire final game in the first week.
- Keep estimates relative to task start and team availability. Do not turn the snapshot date into a deadline.
