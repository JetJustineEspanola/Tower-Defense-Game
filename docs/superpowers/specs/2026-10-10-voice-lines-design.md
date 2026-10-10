# Matthew and Canguit Voice Line Integration

Date: 2026-10-10

## Goal

Integrate the available Matthew and Canguit voice recordings from the linked Google Drive folder into CodeBorn matches. Use each clip's filename as the event cue, keep the existing Jet voice behavior, and play all character lines through the match-level voice player so lines do not overlap.

## Current project context

- `maps/main_map.tscn` is shared by practice and online match scenes. It already contains the `JetVoice` player and the `Experience` announcer.
- `JetVoice` has one `AudioStreamPlayer` on the Voice bus, plus event cooldown and priority handling. The announcer stops the Jet player when a match announcement begins.
- Matthew and Canguit are attacker troop scenes. Matthew is the siege troop; Canguit is the economy troop and generates gold. Canguit has no attack gameplay event.
- The Drive folder contains 13 Matthew clips and 11 Canguit clips. The Jet, Ronel, and Arjie folders are empty.
- The supplied clips are AAC. Godot 4.7 imports WAV, Ogg Vorbis, and MP3, so the project will contain decoded WAV playback assets. The Drive originals remain the source of record.

## Design

Extend the existing Jet voice bank and playback manager to select a bank by character while retaining its current Jet request behavior. Add Matthew and Canguit banks that point to the converted WAV files. Keep one shared player and arbitrate all character events with the existing priority and cooldown approach. When the match announcer starts, it continues to stop a character voice that is playing.

Troops and match controls request a character/event pair from the shared manager at the moment the event happens. Missing clips or missing banks fail silently, as they do for existing optional voice events. No new subtitles or user settings are needed; character audio uses the existing Voice bus and volume setting.

### Matthew event mapping

- `matthew_selected`: player selects a Matthew troop.
- `matthew_deployed`: a Matthew troop finishes training and spawns.
- `matthew_upgraded`: a Matthew roster upgrade is purchased for future troops.
- `matthew_extrasound_attack_01..03`: Matthew completes a normal attack.
- `matthew_extrasound_hurt_01..02`: Matthew takes damage.
- `matthew_extrasound_defeat` and `matthew_defeated`: Matthew dies.
- `matthew_destroys-tower`: Matthew's damage destroys a tower.
- `matthew_bombardment`: Matthew's siege bombardment lands.
- `matthew_blocked-by-guard`: a guard begins blocking Matthew.

### Canguit event mapping

- `open for business` and `lets make this count`: Canguit spawns.
- `keep the route clear`: player selects a Canguit troop.
- `good spot setting up`: Canguit reaches its trading-post position.
- `3 short attack efforts`, `now thats an investment`, and `a little more gold`: Canguit generates gold. The attack-effort clips are used here per the user's direction; Canguit's gameplay role remains economy.
- `2 hurt reaction` and `i could use some cover`: Canguit takes damage.
- `deafeat` and `closing early`: Canguit dies.

Repeated events use random clip selection without immediately repeating the same clip when multiple choices exist. A shared cooldown prevents repeated income events and large groups from flooding the voice channel.

## Scope

- Bring all 24 clips from the two populated Drive folders into the project and convert them to WAV playback files without trimming, gain changes, or pitch changes.
- Add two voice bank resources and extend the existing manager without changing Jet's event map.
- Wire events at the current troop spawn, selection, upgrade, attack, damage, death, blocker, bombardment, tower destruction, stationing, and income points.
- Cover both practice and online matches through the shared map.
- Do not change character gameplay rules, add attack behavior to Canguit, or add content for empty character folders.

## Verification

Use Godot's audio import and scene/script parse checks for the affected project files. Exercise representative Matthew and Canguit events in practice and online matches, including the announcer interrupt and Canguit's income cooldown. Do not add a separate test harness.


