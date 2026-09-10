# CodeBorn Developer Startup Plan

Project board: https://github.com/users/JetJustineEspanola/projects/1/views/2

Repository: https://github.com/JetJustineEspanola/Tower-Defense-Game

Miro reference: https://miro.com/app/board/uXjVHq86R4M=/

## Decision

CodeBorn should begin with one two-hour team kickoff followed by a controlled start order. The Core, LAN, and UI developer creates the shared Godot structure first. Jet starts the graybox and asset contract in parallel. The Economy and Arcane developer and Tower and Combat developer begin as soon as the shared identifiers and service interfaces are committed on the first day. The Bugs, Training, and Pathfinding developer begins after the route, spawn, base-contact, and troop data contracts are fixed, no later than the second day.

Tower upgrades belong with the Tower and Combat developer. Pathfinding belongs with the Bugs and Training developer. This keeps each feature next to the runtime system that must apply and test it.

The first shared target is one complete match slice: two players connect, one defender places one attack tower, one attacker trains one objective bug, the bug follows one path, the tower attacks it, the surviving bug damages the base, and the host declares the result.

## Start order

| Order | Start time | Owner | First output | Start condition |
|---|---|---|---|---|
| 0 | Day 1 first two hours | Whole team | Approved contracts and first-slice rules | Kickoff begins |
| 1 | Day 1 immediately after kickoff | Core LAN UI Integration | Godot project shell and shared service interfaces | Rules and names agreed |
| 1 | Day 1 in parallel | Jet 3D Art | Asset contract and graybox map kit | Scale and pivot agreed |
| 2 | Day 1 after shared skeleton exists | Economy and Arcane | Wallet, mana, and question data skeleton | Player state and transaction API exist |
| 2 | Day 1 after shared skeleton exists | Tower Combat and Upgrades | Tower data, deployment, targeting, and damage skeleton | Entity IDs and combat API exist |
| 3 | Day 2 at the latest | Bugs Training and Pathfinding | Training queue, path agent, and objective bug skeleton | Route and troop contract exist |
| 4 | End of Day 3 | Whole team | First integrated offline graybox | All minimum systems can run in one scene |
| 5 | End of Week 1 | Whole team | First two-instance LAN demonstration | Offline slice works and network commands are defined |

All developers should be active by Day 2. The order controls dependencies; it does not reserve several days for one person to work alone.

## Team responsibilities

| Owner | Primary responsibility | Owns | Does not own |
|---|---|---|---|
| Jet 3D Art | 3D and technical art | Models, rigs, animation clips, materials, graybox environment, GLB delivery and visual checks | Match rules and final gameplay scene wiring |
| Core LAN UI Integration | Application shell and multiplayer flow | Project structure, scene routing, menus, lobby, networking, match state replication, HUD containers, builds and integration | Economy calculations or tower and troop behavior |
| Economy and Arcane | Resources and questions | Gold, mana, validated transactions, passive income, question definitions, rewards, skip and refresh, question panel data | Direct tower placement, targeting or troop movement |
| Tower Combat and Upgrades | Defender structures and combat rules | Deployment nodes, tower lifecycle, targeting, damage, armor, attack types, tower abilities and two-slot upgrade rule | Troop path movement and training queues |
| Bugs Training and Pathfinding | Attacker units and movement | Training queue, spawn timing, Path3D movement, objective contact, siege targeting, troop lifecycle and troop upgrades | Tower placement and tower ability implementation |

The Core LAN UI developer is the integration owner. Every specialist owns defects inside their subsystem and must provide a small test or repeatable verification scene.

## Day 1 kickoff decisions

The whole team must decide and record the following before feature branches diverge:

- Godot 4.6 patch and Windows export target.
- Folder, scene, script, resource, signal, and branch naming.
- World scale, model forward direction, ground pivot, tower footprint, and path width.
- Stable player, entity, tower, troop, ability, deployment-node, command, and transaction identifiers.
- Match phase order and the host-authoritative rule.
- Starting gold and mana placeholders used for the first slice.
- Damage, armor, attack interval, training time, and movement-unit conventions.
- Network request and acknowledgment shapes for purchases, placement, training, damage, and results.
- Which Miro screens are required for the first demonstration.
- Pull-request reviewer and merge order for each work package.

The first values are test values and may change during balancing. Their names, units, and ownership must remain stable.

## Shared technical contracts

Create these typed Godot resources or equivalent documented data objects before building the full roster:

- `TowerDefinition`: stable ID, class, price, footprint, health, armor, attack configuration, income configuration, spawn configuration, and five ability IDs.
- `TroopDefinition`: stable ID, class, price, count, training time, health, armor, movement speed, attacks, base damage, income configuration, and five ability IDs.
- `AbilityDefinition`: stable ID, valid owner type, price, modifiers, effect tags, prerequisites, and UI text.
- `StatBlock`: base values plus ordered modifiers and final computed values.
- `PlayerState`: peer ID, role, ready state, gold, mana, and selected loadout.
- `MatchState`: phase, timer, defender base health, winner, role assignment, and protocol version.
- `EconomyTransaction`: request ID, player ID, reason, amount, related entity ID, server result, and resulting balance.
- `TrainingOrder`: request ID, troop ID, selected abilities, quantity, accepted timestamp, and spawn timestamp.
- `DamageEvent`: source, target, raw damage, damage type, armor result, final damage, and server tick.
- `QuestionDefinition`: ID, format, difficulty, prompt, choices when applicable, accepted answer, explanation, reward, and content version.

UI scripts must request changes from the owning system. They must not directly change gold, mana, health, training queues, tower state, or match results.

## Initial work package for Core LAN UI Integration

**Start:** First, immediately after the kickoff contract.

**Tasks:**

- Create the Godot 4.6 project structure and typed GDScript conventions.
- Add `SceneRouter`, `NetworkManager`, `MatchState`, `SettingsManager`, and an event interface.
- Create the Starting Screen, LAN Browser, Host Lobby, Role Reveal, Main Game shell, and Results shell.
- Implement ENet host and join for two local instances.
- Replicate lobby roster, ready state, random first role assignment, and five-second reveal.
- Provide an authoritative command entry point for economy, placement, training, and combat requests.
- Create a fixed isometric camera with limited zoom.
- Maintain the integration scene and Windows test build.

**Done when:** Two instances connect through localhost, both appear in the lobby, both become ready, the host starts, both see the same roles, and both enter the same graybox match scene without parse errors.

## Initial work package for Jet 3D Art

**Start:** Day 1 in parallel with the project shell.

**Tasks:**

- Publish the futuristic fantasy chibi scale, pivot, forward-axis, naming, material, texture, and animation contract.
- Block out one route, attacker portal, defender base, and three to twelve deployment markers.
- Deliver one attack-tower placeholder and one objective-bug placeholder.
- Provide idle, move, attack, hit, and death clips where relevant, or document static substitutes.
- Verify silhouettes using the fixed isometric camera and HUD safe areas from Miro.
- Store large binary art sources and exports using the repository's Git LFS rules.

**Done when:** The programmers import the map, tower, and bug without correcting scale, origin, forward direction, or filenames, and the route remains readable beneath the HUD.

## Initial work package for Economy and Arcane

**Start:** Day 1 after `PlayerState` and the transaction interface exist.

**Tasks:**

- Implement host-owned gold and mana balances.
- Implement `can_afford`, validated spending, rewards, passive income, and mana regeneration.
- Use unique request IDs to prevent duplicate spending and duplicate rewards.
- Define Coding Fix, Multiple Choice, and Identification question records.
- Create one valid sample question of each type.
- Implement correct-answer reward, difficulty reward, mana skip, and mana refresh.
- Expose read-only resource events for the HUD.
- Create validation for missing answers, duplicate IDs, invalid rewards, and malformed choices.

**Done when:** The host accepts valid transactions once, rejects insufficient funds and duplicates, mana regenerates, and a correct sample answer awards gold exactly once.

## Initial work package for Tower Combat and Upgrades

**Start:** Day 1 after entity identifiers and the combat interface exist.

**Tasks:**

- Implement deployment-node occupancy and server-side placement validation.
- Create a data-driven base tower scene.
- Implement range detection, deterministic target selection, attack interval, armor, damage, death, and cleanup.
- Build one functional single-target attack tower.
- Define single-target, multi-target, and splash attack interfaces.
- Implement the five-ability definition list and enforce a maximum of two selected tower abilities.
- Create two test abilities, such as increased range and splash damage.
- Emit combat events that the network and HUD can display.

**Done when:** A purchased tower occupies one valid node, rejects invalid placement, acquires a living bug, attacks at the configured interval, applies armor correctly, releases invalid targets, and cannot equip a third ability.

## Initial work package for Bugs Training and Pathfinding

**Start:** After the route and troop definition contract are committed, no later than Day 2.

**Tasks:**

- Implement the host-owned troop training queue and spawn timer.
- Create a data-driven base troop scene.
- Implement movement along the agreed Path3D route with stable route progress.
- Build one objective bug that ignores towers and damages only the defender base.
- Implement health, armor, death, cleanup, and safe removal from target lists.
- Create extension points for siege and economy bug behavior.
- Implement the five-ability definition list and maximum two selected troop abilities.
- Create two test abilities, such as increased movement speed and reduced training time.

**Done when:** A valid purchase enters training, spawns once at the correct time, follows the entire route without getting stuck, can die to tower damage, or damages the base once if it survives.

## Week 1 integration schedule

| Day | Required integration result |
|---|---|
| Day 1 | Project shell, contracts, branches, map scale, identifiers, and placeholder data are committed. |
| Day 2 | One map, deployment node, tower shell, troop shell, wallet, HUD labels, and two-instance lobby load together. |
| Day 3 | Offline vertical slice runs from tower purchase and troop training through combat and base contact. |
| Day 4 | Offline commands are routed through host-authoritative request handlers and replicated to a second instance. |
| Day 5 | Team demonstrates one short LAN match, records defects, and updates the board using evidence. |

Every developer integrates at least once by Day 3. No subsystem remains on an isolated branch for the whole week.

## Week 2 target

Week 2 stabilizes the first slice and adds one example of each supporting feature:

- LAN discovery or a documented manual-IP fallback.
- Disconnect handling before and during a match.
- One Arcane Question from each format.
- Passive mana regeneration and one gold reward path.
- Two tower test abilities and two troop test abilities.
- Result screen and safe return to the starting screen.
- Rematch with attacker and defender roles swapped.
- One Windows export tested on two physical devices using the same Wi-Fi or hotspot.

Do not begin the complete roster or all thirty abilities until this gate passes.

## First playable gate

The startup milestone is complete only when all of the following are true:

- Two players connect and enter one lobby.
- Both players become ready and see one synchronized role assignment.
- The defender buys and places one attack tower on a legal deployment node.
- The attacker buys one objective bug and waits for its training timer.
- The bug follows the route while the tower attacks it.
- A dead bug is removed safely, or a surviving bug damages the base once.
- Gold, mana, match time, and base health display authoritative values.
- The host decides victory or defeat and both clients show the same result.
- Returning to the menu does not leave peers, units, timers, or transactions active.
- The exact build runs on two Windows devices over the supported LAN configuration.

## GitHub planning board connection

Create six startup cards in the CodeBorn planning board and link them to the existing M0 and M1 issues:

1. `[START-01] Core LAN UI foundation and shared contracts` - references issues #2, #3, #4, #7, #8, and #9.
2. `[START-02] Economy and Arcane vertical slice` - references issues #2, #4, #5, #7, and #9.
3. `[START-03] Tower combat placement and upgrade framework` - references issues #2, #7, #12, and #17.
4. `[START-04] Bug training pathfinding and objective contact` - references issues #2, #7, #12, and #17.
5. `[START-05] Graybox map and replaceable 3D asset contract` - references issues #1 and #6.
6. `[START-06] Two-player first playable integration gate` - depends on START-01 through START-05 and references issues #7, #8, #9, and #10.

START-01 and START-05 move to In Progress first. START-02 and START-03 become ready after the shared skeleton lands. START-04 becomes ready after the route contract lands. START-06 stays blocked until all five implementation cards provide their minimum outputs.

Attach or link this startup plan from every START card. Keep later milestone cards in Backlog. A card moves to Done only when its stated result is demonstrated in the integrated build.

## Working rules

- Keep at most one primary startup card in progress per person.
- Merge small interfaces and placeholders early instead of waiting for complete features.
- Use data resources for balance values; do not store prices or combat values in UI scripts.
- Use placeholders until final art is ready.
- Record build version, commit, test setup, expected result, actual result, and evidence for failures.
- Review any change that affects identifiers, network messages, save formats, or asset contracts with every affected owner.
- Reestimate after the first two-device demonstration.

