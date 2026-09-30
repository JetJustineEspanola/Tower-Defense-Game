# Troop orders and economy counterplay

In Attacker Practice, click a deployed troop to open its controls. The white ring shows Matthew's bombardment range; Ronel and Canguit have small selection rings. Click empty ground, right-click, or use Close to dismiss the panel. UI nodes are editable in scenes/attacker/troop_orders.tscn.

## Matthew

Choose Nearest, Economy First, Strongest, or Weakest. Strongest/Weakest compare current health. These priorities affect regular attacks within normal range and bombardment within siege range. Guards engaging Matthew take precedence over regular tower targeting and prevent bombardment.

Bombardment deals 30 damage before armor, reaches 8 world units, has a 20-second cooldown, and starts with a 10-second preparation delay. All allied Matthews share an additional 8-second firing lockout. Newly spawned Matthews inherit any active shared lockout. No gold is charged for this ability. Auto bombardment is enabled by default; turn it off to use the Fire button manually. No target or a blocking guard does not consume the cooldown. A golden tracer, impact particles, and normal tower hit feedback show the hit.

This is a limited-range attack, not a whole-map strike. Matthew must advance close enough to reach the backline. It does not attack the base remotely; normal arrival damage is unchanged.

## Ronel

While at least one living Ronel is on the field, opposing economy towers generate gold 25% more slowly. Multiple Ronels do not stack. The effect ends when the last one dies or reaches the base. It affects tower income timing, including income-speed upgrades and Overcharge; it does not reduce Astral rewards or attacker Canguit income. An affected tower displays DISRUPTED above its head.

Ronel always travels toward the base, and Canguit follows allies and earns gold. Their panels explain these fixed roles rather than offering attack priorities they cannot use. These are built-in troop abilities, separate from the two purchased upgrade choices.

## Defender economy

Both the human defender and computer defender may have at most two living economy towers. Destroying one frees a slot. They start at 10 gold every 8 seconds, unchanged purchase price of 80 gold. Ronel disruption changes the unupgraded interval to about 10.67 seconds. Upgrades still apply. Attacker Canguit retains its existing 10 gold every 5 seconds.

## Tuning

Edit resources/attacker/combat_balance.tres in the Inspector to adjust the economy limit/interval, disruption percentage, siege range/damage, initial delay, personal cooldown, and shared delay. Changes apply on the next match. Regular troop stats and upgrades remain in their existing Resources. Values are initial balance settings and need full-match playtesting.

## Validation

Runtime checks cover the player and AI economy cap, no charge for rejected purchases, replacing destroyed economy towers, the 8-second base interval, nonstacking disruption and removal, all four target priorities, backline damage, personal/shared cooldown rejection, newly spawned troop lockout, pause rejection, guard counterplay, actual viewport mouse selection, and clearing selection when the troop dies. Existing computer-defender budget/rebuild/restart checks also pass. This remains local practice, not synchronized LAN gameplay.
