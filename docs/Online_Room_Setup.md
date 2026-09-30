# CodeBorn online play

## Play with a friend
1. Both players must use the latest game from this repository. Restart an already running game after updating it.
2. Open **Play**, enter your name, and choose **Create room**.
3. The host chooses the Astral deck and copies the six-character room code.
4. Your friend enters that code and chooses **Join**. You can be on different networks.
5. Both players choose **Ready up**. The host selects **Start match**.
6. After both maps load, each player sees their role and a five-second countdown.
7. The defender buys towers and protects the core. The attacker trains troops and destroys the core. Each player has a separate wallet and question order.
8. A destroyed core means attacker victory. A surviving core when time expires means defender victory.
9. Both players select **Rematch** to start again with swapped roles. Leaving ends the room.

The match menu changes sound and display options without pausing online combat. All lobby, HUD, sidebars, role reveal, and result controls remain scene-authored and editable in Godot.

## Connection settings
The default service is `wss://tower-defense-game-2vgi.onrender.com/rooms`.
The health page is https://tower-defense-game-2vgi.onrender.com/health.
Both the client and relay use protocol `codeborn-match-1`. If the game reports a version mismatch, update both game copies and deploy the latest relay. Do not simply remove the version check: the old lobby-only relay cannot carry matches.

An address saved through the lobby gear overrides the project default. If you previously used localhost, replace it with the address above. The saved override is in `user://online.cfg`.

## Existing Render service
- Repository branch: `main`
- Root directory: `server/room_relay`
- Build: `npm ci --omit=dev`
- Start: `npm start`
- Health check: `/health`
- Keep one instance because rooms are held in memory.

Push the updated relay to the branch connected to Render. If automatic deployment is disabled, select **Manual Deploy > Deploy latest commit** in the existing service. Wait for the deploy to become live. Its health response should report `codeborn-match-1`.

A sleeping free service may need time to wake. The game allows 75 seconds to connect. Opening the health page can wake the service before creating a room. A deployment or service restart removes existing rooms; create a new code afterward.

## Shared gameplay
The host runs training, movement, blocking, tower attacks, siege abilities, upgrades, gold, mana, question validation, base health, and the match timer. The other player sends actions and receives state updates ten times per second with interpolated positions. Damage sounds, animations, particles, and gold popups are presented locally from host events.

The relay assigns roles, requires both players to load, validates which role can send each action, and forwards commands to the host. Only the host may publish battlefield state or decide the winner. Upgrades bought while a troop is already training affect future training orders. Every question attempt is validated once; a skipped or completed card must cycle back before another attempt. Host PDF/DOCX/TXT reference attachments are not transmitted, only the selected question deck.

This is a private, host-authoritative game for friends, not a cheat-resistant dedicated server. There is no mid-match reconnect or host migration yet. A disconnect ends the match with a clear message and a way back to the lobby. Two computers on different networks still need a human play session before a public release.

## Developer notes
- Main online scene: `scenes/network/online_match.tscn`
- Persistent connection: `scripts/network/online_room_client.gd` (`OnlineSession` autoload)
- Simulation and replication: `scripts/network/online_match.gd`
- Offline practice remains under **Developer** in the main menu.
- Relay regression suite: run `npm test` inside `server/room_relay`.
- Local relay: run `npm start`; use `ws://127.0.0.1:8080/rooms` in both local clients.

The implementation includes role-scoped commands, duplicate-command protection on the host, version matching, deck revision acknowledgments, payload and message-rate limits, loading timeout, heartbeat cleanup, and slow-connection backpressure. Keep the same game build on both computers.
