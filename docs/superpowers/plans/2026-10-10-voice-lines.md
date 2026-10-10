# Matthew, Canguit, and Ronel Voice Lines Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Play all supplied Matthew, Canguit, and Ronel voice lines at their filename-matched gameplay events in practice and online matches.

**Architecture:** Extend the existing Jet voice bank and manager with character-aware requests while retaining Jet's event and playback behavior. Store decoded WAV assets and per-character banks under `voice_lines/`, and call the shared manager from troop, roster, selection, and spawn event sites.

**Tech Stack:** Godot 4.7, typed GDScript, Godot `AudioStream` resources, AAC-to-WAV decode.

---

## File map

- `scripts/combat/jet_voice.gd`: shared arbitration, cooldown, event-to-bank selection, and actor validation; preserve Jet callers.
- `scripts/combat/jet_voice_bank.gd`: shared event-array resource schema, expanded only for needed character events.
- `scenes/combat/jet_voice.tscn`: existing shared playback node; retain the one `Voice`-bus player.
- `scripts/attacker/attacker_troop.gd`: deployed, attack, siege, income, hurt/death, stationing, blocked guard, Ronel phase/low-health, and tower-destruction requests.
- `scripts/attacker/attacker_match.gd`: troop spawn request if it does not originate in the troop script.
- `scripts/attacker/troop_orders.gd`: selection request.
- `scripts/attacker/troop_roster.gd`: roster upgrade request.
- `maps/main_map.tscn`: preserve existing shared JetVoice node; only change if the manager scene needs a compatible bank registry property.
- `voice_lines/Matthew/*.wav`, `voice_lines/Canguit/*.wav`: 24 decoded playback assets, retaining stable names derived from Drive filenames.
- `scripts/attacker/troop_orders.gd`: selection requests for Matthew, Canguit, and Ronel.
- `voice_lines/Matthew/*.wav`, `voice_lines/Canguit/*.wav`, `voice_lines/Ronel/*.wav`: 31 decoded playback assets, retaining source-derived names.
- `voice_lines/Matthew/matthew_voice_bank.tres`, `voice_lines/Canguit/canguit_voice_bank.tres`, `voice_lines/Ronel/ronel_voice_bank.tres`: event-to-clip resources.
- `docs/superpowers/plans/2026-10-10-voice-lines.md`: this implementation plan.

## Task 1: Bring in and decode the supplied recordings

**Files:**
- Create: `voice_lines/Matthew/*.wav`
- Create: `voice_lines/Canguit/*.wav`

- [x] Fetch the 13 Matthew and 11 Canguit AAC files from the already identified Drive folders by their metadata-backed file links. Save each connector-provided file reference into its matching character folder; do not expose or manually reuse nested signed URLs.
- [x] Decode AAC to PCM WAV without trimming, normalization, resampling where avoidable, or pitch/time changes. Use the available system decoder; if `ffmpeg` is unavailable, check installed workspace media runtimes for a decoder before selecting a compatible decode utility.
- [x] Confirm there are exactly 13 Matthew and 11 Canguit WAV files and each is non-empty/readable. Keep any temporary AAC copies outside the project unless they are required as source assets; the Google Drive originals remain authoritative.

## Task 2: Extend the shared manager and bank schema

**Files:**
- Modify: `scripts/combat/jet_voice.gd`
- Modify: `scripts/combat/jet_voice_bank.gd`
- Modify: `scenes/combat/jet_voice.tscn` only if needed to export the new bank references

- [x] Add a character-keyed bank map for Jet, Matthew, and Canguit; keep existing `request(event, actor)` as a Jet-compatible wrapper so `starter_tower.gd` does not need broad changes.
- [x] Add `request_for(character: String, event: String, actor: Node) -> bool`. Resolve the bank by character, validate the active match/player resources for attackers, and retain the current pause, match-clock, announcer-interrupt, arbitration, cooldown, and no-immediate-repeat behavior.
- [x] Add named event arrays required by the approved mapping (`deployed`, `stationed`, `income`, `guard_blocked`, `tower_destroyed`, `bombardment`), retaining Jet's existing fields and aliases. Share cooldowns among synonymous attack and hurt variations within each character; give income a cooldown suitable for recurring gold ticks.
- [x] Confirm requests for absent banks or empty event arrays return `false` without interrupting the active clip. Jet keeps the same priorities, mappings, Voice bus, and volume.

## Task 3: Add character bank resources

**Files:**
- Create: `voice_lines/Matthew/matthew_voice_bank.tres`
- Create: `voice_lines/Canguit/canguit_voice_bank.tres`

- [x] Map Matthew files: selected, deployed, upgraded, `extrasound_attack_01..03` as attack variants, `extrasound_hurt_01..02` as hurt variants, both defeat files as defeated variants, destroys-tower, bombardment, blocked-by-guard.
- [x] Map Canguit files: both spawn clips as deployed variants; keep-the-route-clear as selected; good-spot-setting-up as stationed; all three attack-effort/investment clips as income; both hurt clips as hurt variants; deafeat and closing-early as defeated variants.
- [x] Preserve source spelling in filenames and resource paths, including `deafeat.aac`'s decoded WAV name, while exposing clean event keys in the resources.

## Task 4: Wire match and troop gameplay events

**Files:**
- Modify: `scripts/attacker/attacker_troop.gd`
- Modify: `scripts/attacker/attacker_match.gd` if spawn occurs there
- Modify: `scripts/attacker/troop_orders.gd`
- Modify: `scripts/attacker/troop_roster.gd`

- [x] Request `deployed` once after each Matthew/Canguit troop finishes training and becomes active. Selection requests `selected`; roster upgrade requests `upgraded` for Matthew only when its upgrade purchase succeeds.
- [x] At a successful Matthew normal hit, request a random `attack` variation. On each valid damage event request a random hurt line; on death request a random defeated line once.
- [x] At Matthew's successful siege impact, request `bombardment`. When its hit destroys a tower, request `tower_destroyed` in addition to bombardment, letting normal priority arbitration select what can play.
- [x] When a guard begins blocking Matthew, request `guard_blocked` once per engagement. When Canguit reaches its reserved trading-post offset, request `stationed` once.
- [x] When Canguit adds gold in its existing income tick, request `income`; do not add any attack behavior or extra gold generation.
- [x] Route every request through the match's shared `JetVoice` node so practice and online share the same behavior. Confirm announcer requests still stop the shared player.

## Task 5: Verify affected project files and gameplay integration

**Files:** all files created or modified above.

- [x] Check the working-tree diff to confirm only the plan, voice manager/banks, audio assets, and event call sites changed.
- [x] Run Godot 4.6.3 headless project asset import and runtime startup; inspect logs for parser, resource, and startup errors. Both completed with exit code 0 and no matching errors.
- [ ] In practice, trigger representative Matthew selection, deploy, attack, bombardment, hurt, guard block, tower destruction, upgrade, and death events, then trigger Canguit spawn, selection, stationing, income, hurt, and death.
- [ ] Confirm repeated Canguit income does not flood the shared voice channel, repeated multi-clip events avoid immediate repeats, and match announcements interrupt character playback.
- [ ] Confirm an online match uses the same shared map path and that voice requests are local presentation only, without changing synchronized gameplay state.

## Ronel extension

- [x] Decode the seven user-supplied `.m4a` clips to PCM WAV, keeping the original basenames.
- [x] Map “One step ahead” to selection, “see the finish line” to deployment, “you_re slowing me down” to blocking, “Ready to break though !” to the guard-phase start, “made it through” to the guard-phase end, “can_t hold me” to hurt, and “just a little further” to the first low-health threshold.
- [x] Register Ronel's bank on the shared JetVoice scene and allow objective-role troops to request it.
- [x] Run Godot 4.6.3 headless project asset import and runtime startup; inspect logs for parser, resource, and startup errors. Both completed with exit code 0 and no matching errors.
- [ ] Manually verify Ronel event playback in an interactive match.

## Self-review

- All 31 clips are covered: 13 Matthew, 11 Canguit, and seven Ronel, with grouped arrays for variations.
- Each filename-based event in the approved design has a corresponding resource mapping and a live gameplay call site.
- Canguit attack-effort clips trigger on existing gold income, not on an invented combat event.
- Jet behavior and one-player/announcer arbitration remain compatible.
- No tests are added; verification is limited to a Godot import/parse pass and manual gameplay checks.
