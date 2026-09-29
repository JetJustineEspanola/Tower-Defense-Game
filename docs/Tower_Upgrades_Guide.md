# Tower upgrades

Run the main map, buy a tower, then click its character or occupied deployment pad.
The right sidebar shows its portrait, stats, five choices, ownership and gold costs.
The white circle marks attack range for Jet, guard deployment radius for Arjie,
and bounty collection radius for Canguit. Closing the sidebar restores the question
panel to its previous state. Match time continues while the sidebar is open.

## Editing upgrades in Godot

1. Open resources/upgrades/jet_path.tres, arjie_path.tres or canguit_path.tres.
2. Edit the character name, portrait, role or choice limit in the Inspector.
3. Expand Choices and select an ability Resource to edit its title, description,
   cost and effect fields. Alternatively open that ability's .tres file directly.
4. Descriptions are editable text; update them whenever you change their numbers.

To create another ability using the existing effects, duplicate an ability .tres,
give it a unique ID, configure its modifiers, and assign it to a path's Choices.
Each starter path has five choices and a two-choice limit. Each purchase is permanent
for that tower during the match. Each path ID must be unique within its choices.
The sidebar contains five scene-authored Button nodes. If you expand beyond five,
also extend those rows and the rows array in tower_upgrade_sidebar.gd.

TowerUpgrade contains reusable stat modifiers and special-effect settings.
TowerUpgradePath groups the choices. Tower instances store purchased IDs separately;
purchasing never mutates the shared Resource. Adding a completely new kind of mechanic
requires implementing its behavior and exposing a new Resource field.

## Current effects

Jet: Sharper Slash (+8 damage), Quick Draw (interval x0.8), Long Reach (+0.7 range),
Piercing Qi (one secondary enemy within the forward 70-degree arc, 50% damage),
Burning Edge (4 damage/second for 3 seconds, refreshed rather than stacked).

Arjie: Reinforced Guard (+30 guard health), Twin Summon (maximum two guards),
Rapid Summon (interval x0.75), Stronger Blade (+5 guard damage), Hold the Line
(two blocked bugs per guard; the guard still attacks one enemy at a time).
Guard stat upgrades update surviving guards as well as future guards. Extra guards
arrive at the next summon check. Guards are replaced only when slots are missing.

Canguit: Bigger Payout (+5 gold), Faster Ledger (interval x0.8), Bounty Ledger
(3 gold per nearby death, awarded once to the nearest eligible living tower),
Astral Bonus (+5 gold per correct answer; the highest bonus applies once),
Iron Vault (+60 tower health, +3 armor).

All costs and values are prototype balance settings. Income interval changes restart
the payout timer and never grant an immediate payout. A correct answer still grants
its normal question reward. Bounty does not trigger when a bug reaches the base.

Iron Vault works through the tower's take_damage API. Full siege-troop targeting
remains a separate feature; current objective bugs do not attack towers.

## Scene editing

scenes/towers/tower_upgrade_sidebar.tscn owns the visible UI nodes.
scenes/towers/tower_selection.tscn owns the white circle and click collider.
Each tower scene exposes its Upgrade Path property and instances the selection scene.
The sidebar closes when the tower is destroyed or the match timer expires.

Validation covered all fifteen effects, duplicate/third/unaffordable purchases,
gold deductions, independent tower ownership, range changes, blocking capacity,
death rewards, popup selection, and restoration on close.
