# Starter tower placement

Run the main map with F5. Click/tap any glowing deployment pad, choose a tower,
or Cancel. Escape closes the picker. Collapse the question sidebar to reach
pads behind it.

Economy costs 80 gold, Attack costs 100, and Defense costs 120.
Starting gold is still 100. Answer questions to afford more towers.
The shared resource controller charges once and updates the top bar immediately.
Unaffordable choices are disabled; occupied pads cannot accept another tower.
Purchases are rejected while paused or after the countdown ends.

The editable placeholder models now have working behavior:

- Economy grants 10 gold every 5 seconds through the shared resource controller.
- Attack deals 20 damage every second to the nearest living bug within 2.5 m.
  A short cyan beam shows each hit.
- Defense checks every 8 seconds and deploys one guard on the nearest point of
  the road if its previous guard is gone. A guard blocks one bug at a time.
  Guards have 60 health and deal 10 damage per second; bugs deal 15 back.
  Other bugs may pass an occupied guard. A freed or dead guard releases its bug.

Use Send practice bug to spawn one bug at the portal. This is a manual review
control, not waves or the final attacker training queue. Bugs have 60 health,
follow the map's Path3D, and damage the base by 10 once on arrival.
Pause freezes tower timers, guards and bugs. Countdown expiry or base destruction
stops income, combat and movement; a full results screen is still separate.

## Edit in Godot

- scenes/towers/tower_shop.tscn: all picker Labels and Buttons are scene nodes.
  Change the root's Costs and Tower Scenes arrays in the Inspector, keeping
  the order Economy, Attack, Defense.
- scenes/towers/economy_tower.tscn, attack_tower.tscn, defense_tower.tscn:
  replace the Base/Core meshes with your models. Keep the root at the base pivot.
- scenes/towers/placement_pad.tscn: clickable cylinder on physics layer 4
  (bit value 8). Each map PlacementCenter contains one pad instance.
- Tower roots expose income, damage, range and timer interval. The ActionTimer,
  beam, mesh and label are scene-authored nodes.
- scenes/towers/defender.tscn and combat_bug.tscn hold the reusable actors.
- The picker reuses assets/ui/resources/frame.svg and the HUD icon textures.
- maps/main_map.tscn: Gameplay/TowerShop has Editable Children enabled.

Placement state belongs to each pad. The shop validates the pad, cost, pause,
clock and funds before instancing. It reserves the pad before resource signals
emit, preventing duplicate transactions. UI contains no separate gold balance.

Verified in Godot 4.6: physical pad click, seven pads, all three purchases,
immediate gold label update, insufficient funds, occupied pad and pause guards.
Also verified timer income, in-range kills, guard spawning, mutual damage,
movement stopping/resuming, guard replacement and income stopping at match end.
