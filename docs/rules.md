# CodeBorn rules version 0.1

These rules freeze the implemented graybox and define the expansion boundaries. The supplied development plan is design reference material; the user's explicit first-slice requirements control scope. Balance values are prototype values, not playtest conclusions.

| Rule | Implementation |
| --- | --- |
| Roles | Random attacker/defender once after both ready; host role is independent; both rematch votes swap roles |
| Start | Both compatible peers load role reveal; five host-timed seconds; 15 seconds preparation |
| Match timer | Default 720 active seconds; lobby selection 600–900 seconds |
| Preparation | Build and queue allowed; movement, combat, training, income and questions frozen |
| Outcome | Attacker wins at zero core HP; defender wins when time ends with HP remaining |
| Final tick | Movement, attacks/deaths, base contacts, income, then outcome; lethal contact beats survival |
| Resources | Start 300 gold/40 mana; attacker earns 6 gold/s, defender 4; mana regenerates 1/s; caps 9999/100 |
| Core | 1000 HP, zero armor, no repair or regeneration |
| Towers | Pulse Spire costs 120; 18 damage/s; range 9; one tower per predefined node |
| Troops | Core Runner costs 70 per squad of 3; six-second training; 80 HP, speed 2.2, 35 contact damage each |
| Training | Two parallel FIFO lanes, eight orders total, 60 live plus reserved population; no waves |
| Targeting | Furthest route progress first; stable entity ID breaks ties |
| Contact | A dead unit cannot hit the core; each living arrival damages once and is consumed |
| Abilities | Two distinct permanent choices per tower / troop blueprint; queued and existing troops retain purchased snapshots |
| Ability price | Tower slots 60/100; troop blueprint slots 120/180 gold |
| Questions | Host validates text; one active slot per player; generation 30 mana; single final answer; no repeat in three-question pack |
| Rewards | Reviewed record reward 1–60; rolling 120 gold per 60 active seconds cap; no double reward on retry |
| Pause | LAN gameplay continues while answering or viewing a confirmation; no pause command |

Five allowed IDs exist for each implemented archetype. All Pulse Spire modifiers and four Core Runner modifiers are implemented. Phase Step is explicitly disabled until guard blocking exists; its reserved ID remains part of the art/content contract. Secondary tower damage does not recursively fork/splash/slow. Slow refreshes to two seconds and never stacks. Ability cooldowns retain normalized progress.

Future roster rules from the plan remain documented integration requirements: Mana Mint cap 3, Sentinel Gate cap 4, guards release after bounded 3-second blocking with 6-second global immunity, and Cache Mite live/reserved cap 3 with diminishing income ranks. These mechanics are not active in this slice; contributors must not infer that placeholder scenes implement them.

## Reference differences

- The local project skill's older Primal Towers wave and zero-gold-defeat assumptions conflict with the explicit CodeBorn request. CodeBorn uses continuous training, baseline income, and core/timer outcomes.
- The plan recommends a roughly 120-unit route. This graybox's authored S route is 172 units; the larger spacing keeps the bends and twelve node markers distinct. Route length is calculated from the map, never duplicated in movement code.
- The plan's full journey includes cosmetic loadout. The requested first slice proceeds from reveal to preparation with default visuals. Loadout, custom portraits, and full release navigation remain later UI work.
- JSON files are used instead of custom Resource subclasses, as permitted by the request. They are immutable definitions; runtime state is separate.
- Full roster, all thirty abilities, sell/cancel, custom pack publishing/review workflow, question skip/difficulty selection, practice, hotkey rebinding, and production art/audio are later milestones.
- Snapshots use reliable channel 1 at 10 Hz for the bounded graybox, rather than the plan's unreliable motion snapshots plus checkpoints. This simplifies lifecycle consistency; adverse-network performance remains M6 work.
- The supplied DOCX exists at repository root, not `outputs/`. The two named backlog files were absent. GitHub issues #1–40 supplied the task acceptance criteria.
- Miro could not be opened with the available web/browser tools. The explicit written palette/composition in the request was implemented; fidelity to the actual board is unverified.
