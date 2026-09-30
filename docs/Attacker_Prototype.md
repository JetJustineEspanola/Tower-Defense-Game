# Attacker prototype

Open `scenes/attacker/attacker_match.tscn` in Godot 4.6 and press **F6** (Run Current Scene). F5 still launches the existing project start scene.

This is a local practice match against three preset towers. It does not connect to a LAN defender yet.

## Play

- Start with 300 gold and 12 minutes. Use the existing question sidebar for extra gold.
- Click Train on Ronel, Matthew, or Canguit. Gold is paid immediately. Each card has one independent training slot and automatically spawns its troop when training finishes. Click again to order another troop; training does not repeat indefinitely.
- Ronel follows the path and deals 15 base damage. He does not attack towers or guards.
- Matthew stops to fight nearby towers or blocking guards and deals 8 base damage if he reaches the end.
- Canguit earns 10 gold every 5 seconds while alive, waits behind combat troops, and deals no base damage. When no combat troops remain, he continues along the path and leaves at the endpoint.
- Click Skills to choose up to two of five upgrades for that troop type.
- Upgrades affect orders started after purchase. Existing troops and orders already training retain their original stats.
- Destroy the enemy base to win. If time expires with the base alive, you lose. Menu pauses the match; results offer Retry or Main menu.

## Edit in Godot

| What to change | Where |
| --- | --- |
| Bottom card layout, buttons, labels and portrait size | `scenes/attacker/troop_card.tscn` |
| Bottom bar position and result screen | `scenes/attacker/attacker_match.tscn` |
| Shared top bar and question UI | `scenes/Arcane_question/arcane_question_test.tscn` |
| Shared skill sidebar | `scenes/towers/tower_upgrade_sidebar.tscn` |
| Troop price, health, training, speed and damage | `resources/attacker/ronel.tres`, `matthew.tres`, `canguit.tres` |
| Five skill choices, portraits and two-choice limit | The corresponding `*_path.tres` resources in that folder |
| Individual skill cost, icon, short description and bonuses | The individual upgrade `.tres` resources in that folder |
| Starting gold, enemy base HP, troop limit and preset towers | Select the AttackerMatch root and edit its exported Inspector properties |

UI controls are saved scene nodes. Scripts update their values and visibility. Inherited/instanced controls can be opened in their source scenes to edit them. Shared HUD or sidebar changes also affect the defender scene.

There is a 60-troop limit including reserved training slots. Costs and stats are initial tuning values, not final balance.

## Next review

1. Play a full match and tune training times, prices, income and base damage.
2. Review all three troop roles against the preset defenders and their guards.
3. Once the local rules feel right, connect training, purchases, combat and the match clock to host-authoritative LAN gameplay.

Verified in Godot 4.6: independent training, duplicate-order prevention, automatic spawning, pause, upgrade snapshots, siege damage, income, endpoint damage, victory and timeout defeat.
