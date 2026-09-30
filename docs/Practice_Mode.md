# Practice mode

Press F5. The game now opens the starting menu. Choose **Developer**, then **Defender** or **Attacker**.

Both modes start with 300 gold and last 12 minutes by default. Your selected Astral question deck is used. The pause menu stops combat, training, income, and the match clock. Results offer Retry/Play Again and Home.

## Defender

Scene: scenes/practice/defender_practice.tscn

Build towers on the deployment nodes and protect the base. A simple computer attacker begins training after a 20-second preparation period. Its repeating purchase plan is Ronel, Canguit, Matthew, Ronel. Each unit must finish its normal training time before appearing.

The computer has a separate wallet: 150 starting gold, plus 15 gold every five seconds. It pays the same troop costs as the player; Canguit also earns income while alive. It waits when it cannot afford the next order. At most 24 computer troops can be active. This is continuous training, not a wave system.

Ronel damages the base by 15 on arrival. Matthew attacks nearby towers and damages the base by 8 on arrival. Canguit earns income and deals no base damage. All values come from the existing troop Resources.

Win by keeping the base alive until time expires. Lose if the base is destroyed.

## Attacker

Scene: scenes/attacker/attacker_match.tscn

Train troops from the three cards. The map starts with no towers. The computer defender has its own 300 gold and makes its first purchase after five seconds, then considers another purchase every eight seconds. It normally opens with an economy tower, but prioritizes an attack tower if troops are already approaching.

The computer pays normal tower and upgrade costs, chooses free deployment nodes near the path for combat towers, and builds up to six towers. It adds attack and defense towers, buys up to two upgrades per tower, and replaces destroyed defenses when it can afford them. Economy towers generate its income. It also simulates an Astral answer every 20 seconds with 75% accuracy, using rewards from the selected deck. Later questions cost 10 mana, and mana regenerates by one every five seconds. This is a timed simulation of answering, not automatic reading or solving of notes.

Win by destroying the base before time expires. Lose if it survives. Gold, training queues, enemy towers, guards, questions, timer, and base health reset when restarting.

## Change match length in the Inspector

1. Open either practice scene listed above.
2. Select its top/root node: **DefenderPractice** or **AttackerMatch**.
3. Find **Match Duration Seconds** in the Inspector.
4. Use **60** for a one-minute test, or **720** for a normal twelve-minute match.
5. Save the scene, then run it with F6 or launch it from the menu.

The root setting is applied to the match clock at startup. Change this setting rather than the nested HUD clock. Each practice scene has its own setting.

You can also change **Starting Gold** on either root. For the defender's computer difficulty, select **ComputerAttacker** and adjust Opening Delay Seconds, Order Delay Seconds, Passive Gold, Income Interval Seconds, Active Troop Limit, or Training Pattern. Select its **Wallet** child to change the computer's Starting Gold.

For the attacker practice opponent, select **ComputerDefender** in the attacker scene. Adjust **Opening Delay Seconds**, **Decision Interval Seconds**, **Maximum Towers**, **Answer Questions**, **Question Interval Seconds**, or **Question Accuracy**. Select **DefenderResources** to adjust its starting gold and mana. Shorter delays and higher accuracy make the opponent stronger.

## Checks completed

Automated runtime checks exercised the actual Developer and role buttons, AI gold spending and training, all three AI troop types, troop arrival damage, pause behavior, both results for both roles, three consecutive restarts for each role, and returning home. Separate checks cover the configurable match duration.

Additional computer-defender runtime checks verified an empty opening, delayed purchases, budget accounting, economy income, question rewards and mana costs, the upgrade limit, rebuilding, pause/end behavior, an empty restart, and responding to incoming troops.

This is local practice. LAN matchmaking and synchronized multiplayer remain separate work. Full-length team playtests are still needed to balance difficulty.

