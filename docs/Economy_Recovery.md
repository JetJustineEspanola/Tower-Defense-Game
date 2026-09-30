# Economy recovery and attacker upgrade incentives

Both practice players receive 5 gold every 5 seconds through the shared BaseIncome node in main_map.tscn. Pausing or ending the match stops income. Restarting resets elapsed time. The old computer-attacker 15-gold income was removed; it now receives the same baseline. Economy units/towers and question rewards are additional income.

Below 50 gold, the existing Next / skip button becomes Emergency refresh - FREE whenever its 20-second cooldown is ready. The first emergency refresh is immediately available when eligible. Refresh advances the existing shuffled deck without granting gold or resetting question history. Correct answers still earn normal rewards. Paid refresh remains available during the cooldown when there is enough mana. At 50 gold or more normal mana costs apply. The tooltip explains the baseline and emergency cooldown.

Each attacker troop type gets its first upgrade for at most 80 gold (a cheaper listed upgrade keeps its lower price). Its second upgrade uses the listed price. The sidebar shows the actual cost and discount; purchases announce Future troops upgraded. Existing troops and training snapshots retain their old stats. Five choices and two purchases remain.

A player may have three living attacker Canguits, including the two possible Trading Posts. An active training order reserves a slot, preventing a fourth purchase. Losing a unit frees a slot. The computer attacker obeys the same limit and skips a capped economy entry rather than stalling its whole training plan.

Tune these defaults in resources/attacker/combat_balance.tres. No replacement discount or second-upgrade training bonus was added. Baseline income alone yields only one gold per second; answering questions remains the faster recovery route. Full-match playtesting is needed to assess recovery times.

Runtime checks passed for shared income on both sides, pause/end stopping income, no duplicated AI stipend, emergency threshold/cooldown/deck advancement, upgrade price displayed and charged, snapshot isolation, Canguit cap with training reservations, and replacing a destroyed Canguit.
