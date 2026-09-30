# Combat presentation and abilities

Start with F5 > Developer > Defender or Attacker.

## Active abilities

- **Overcharge:** select a placed tower, then press the button at the upper left. Its actions are 50% faster for six seconds. This accelerates attacks, economy income ticks, or guard replacement attempts, depending on the tower. It does not exceed a defense tower's guard limit.
- **Rush:** press the button after training troops. All your currently deployed troops move 50% faster for six seconds. Guards still block them and siege troops still stop to attack towers.
- Both abilities have a 40-second cooldown beginning at activation. Clicking without a valid tower or troop does not consume the cooldown. Pausing freezes the effect and cooldown.

Select the Experience node in the shared match scene to adjust ability duration, multiplier, and cooldown. These are temporary modifiers; purchased upgrade values remain intact.

## Feedback

- A damaged base shows a cracked energy shield and hit particles; its nearby light weakens with health and turns red when critical.
- Base critical warnings occur once per match at 25% health or below.
- The final minute changes the timer color and slightly increases combat music speed.
- Tower cards show a translucent model and white range preview on hover or keyboard focus before purchase. The panel moves above or below the selected map area.
- Deployment and upgrades have a small visual pulse. Existing idle, strike, summon, and income animations remain in use.
- A correct Astral answer plays a short original two-tone sound and moves its gold popup toward the resource bar. Wrong answers keep the existing short explanatory feedback.
- Results include base damage and towers destroyed for attackers; bugs defeated and the tower with the most recorded direct damage for defenders. Guard damage counts toward its parent tower. Burn damage is not included in the direct-damage ranking.
- Question gold and correct-answer totals are recorded per match. Question gold counts the card's reward; separate economy-tower question bonuses remain part of total earned gold.

## Audio and comfort

Open Menu during a match for separate Music, Sound effects, and Announcer sliders. Zero mutes a category. Announcer subtitles and reduced particle effects are optional. Settings save locally in user://presentation.cfg.

Reduced effects suppress the new base shield, most summon/income bursts, damage sparks, and ability auras. It preserves the red attack slash and damage numbers so attacks remain readable. It is not a global setting for every decorative map animation.

## Announcer

The seven files in assets/audio/announcer are a replaceable local synthesized English version, generated using Windows System.Speech with **Microsoft Zira Desktop**, rate 0. This is not a custom neural AI voice or a recording of a team member.

Events: defender start, attacker start, own core critical, enemy core critical, final minute, victory, and defeat. Only one announcement plays at a time. Critical warnings and match results can interrupt less important announcements. A lower-priority event occurring during a higher-priority line is dropped to avoid stale queued announcements.

Character speech is intentionally absent until the team provides recordings. There are no substitute character voices.

## Files to adjust

- scenes/combat/match_experience.tscn: ability control, subtitles, notices, audio players, base effect and light.
- scripts/combat/match_experience.gd: event handling, ability rules, settings and statistics.
- scenes/combat/boost_aura.tscn: temporary ability particles.
- assets/shaders/core_shield.gdshader: damaged shield appearance.
- scenes/Arcane_question/arcane_question_test.tscn: editable pause audio controls.
- scenes/towers/tower_shop.tscn: editable compact deployment menu.
- scenes/UI/match_result.tscn: editable results and highlights.
- default_bus_layout.tres: Master, Music, SFX and Voice audio routing.

Runtime checks cover ability activation, expiry, cooldown, pause behavior, deployment preview and purchasing, base damage, announcer priorities, question feedback, result statistics, and loading all seven voice clips. Practice outcome/restart regression checks also passed. Full-length playtesting and a human listening review remain useful before final balancing.
