# Arjie guard orders

Arjie's base deployment/patrol radius is now 5 units (previously 2.5). Matthew currently reaches 3.3 units with Long Barrel, so guards can intercept him inside Arjie's radius. The main Arjie remains a summoning tower; the small guards walk up to fight.

In defender mode:

1. Click a small Arjie. His selection ring and his parent tower's white patrol circle appear.
2. Click the path inside the white circle. A green marker shows the new rally point.
3. The guard walks there, intercepts enemies within the tower's patrol radius, and returns to his rally point after combat.
4. Right-click or press Escape to cancel selection.

Orders outside the patrol circle or away from the path are rejected without moving the guard. Moving a guard releases enemies he was blocking and cancels any pending hit, preventing attacks from landing remotely. Orders are disabled while paused, after the match ends, and for enemy guards in attacker mode.

Orders apply to the selected guard, not future replacements. Movement currently uses direct walking between positions; it does not navigate around decorative obstacles.

Adjust attack_range on scenes/towers/defense_tower.tscn to change the patrol radius. Selection and rally markers are editable scenes. Runtime checks verified mouse selection, movement, invalid destinations, interception and damage against an upgraded Matthew, releasing blocked enemies, pausing, and cleanup after guard death.
