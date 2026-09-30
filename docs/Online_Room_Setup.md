# CodeBorn online rooms — setup

## What works now
Main Menu > Play opens the online lobby. Create room returns a six-character code. Copy it and send it to your friend. They enter their name and code, then Join. Both players see names and readiness. Only the host can choose the Astral deck. Changing it resets readiness; question data is shared, but reference PDF/DOCX/TXT attachments stay local.

This is the online room foundation. Combat synchronization, role reveal, match start and rematches are the next work. The match button deliberately stays unavailable instead of launching two disconnected practice games. Practice remains under Developer in the main menu. The previous LAN UI scene is preserved.

## Test on one computer
Install Node.js 22 or newer. Open a terminal inside server/room_relay. Run npm ci, npm test, then npm start. The service starts on port 8080. Open two game instances. On both, click the gear in the join panel, enter ws://127.0.0.1:8080/rooms, then Save connection. Create a room in one and join by its code in the other. Leave/disconnect closes or updates the room. Stop the service with Ctrl+C after testing.

## Make it available between different networks
The service is ready for a Render Node Web Service, but has not been deployed. You will need your own Render account and to publish these files to your repository first.

1. In Render choose New > Web Service and connect the Tower-Defense-Game repository and branch containing this change.
2. Set Root Directory to server/room_relay, runtime Node, Build Command to npm ci --omit=dev, and Start Command to npm start.
3. Set the health check path to /health. Keep exactly one instance: room state is currently held in memory. No database is needed for this prototype.
4. Choose Free for initial testing, or an always-on paid instance for reliable sessions. Free services can sleep and take about a minute to wake. The client allows 75 seconds to connect; if it fails, visit the HTTPS /health URL and retry. Service restarts remove rooms, so create a new code.
5. When deployment succeeds, Render provides an HTTPS URL. Convert it to a WebSocket address, for example wss://codeborn-room-relay.onrender.com/rooms. This is an example, not a live endpoint.
6. Open resources/network/room_connection.tres in Godot and set relay_url to your actual address. Export the same updated game build for both players. They can then Create/Join without entering a service address. The gear can override it for development; overrides are saved locally in user://online.cfg.
7. Test with two Windows computers on different networks. No player router port forwarding is needed because both connect outward to the hosted service.

Alternatively render.yaml in the service directory describes the same configuration for a Render Blueprint. Choose the instance plan in your account; no paid service has been created by Codex.

## Implementation and next work
Godot uses WebSocketPeer and explicit JSON messages; this is not automatically wired into Godot MultiplayerAPI/RPC. The Node service currently validates and distributes lobby state only. The next implementation must add host-authoritative gameplay command/state messages over this connection, or intentionally introduce a transport adapter. Never run damage, income or troop training independently on both computers.

Suggested sequence: common battlefield and role assignment; player wallets/purchases/training; host-run movement/combat/guards; question attempts and rewards; result/rematch/disconnect. Keep UI, camera, particles and audio local. WebSocket traffic is reliable and ordered, so limit movement updates and interpolate visuals rather than streaming every frame. Measure gameplay responsiveness on the intended connections before release.

Limits: two players per room; 100 simultaneous rooms and 256 open clients per service instance; 256 KB incoming messages with a smaller client-side deck limit; six-character unpredictable room codes; matching protocol build; heartbeat cleanup; message rate limiting; host-only deck updates; server validation and deck revision acknowledgments before readiness. Anyone with a room code can join an empty slot, so share it with your intended opponent. This prototype has no player accounts or host migration. Public-room hosting would require further deployment protection and load testing.

References: https://render.com/docs/websocket ; https://render.com/docs/free ; https://docs.godotengine.org/en/4.6/tutorials/networking/websocket.html
