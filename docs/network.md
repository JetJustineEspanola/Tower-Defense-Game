# Network protocol and authority

Protocol 1 / build 0.1.0 uses Godot 4.6 ENet over UDP. Defaults are gameplay 24560 (configurable 1024–65535) and discovery 24561. Gameplay is exactly two accepted players. The socket permits a small number of transient handshake connections so a third player can receive an explicit full-lobby rejection; only two roster members may issue commands. No object decoding, remote code execution, host migration, reconnect, or internet matchmaking is enabled.

## Session sequence

Join connects to the entered/discovered IPv4 and port. A reliable hello sends protocol, exact build, SHA-256 of catalog/map/canonical question data, and a bounded display name. The host rejects mismatches, empty/oversized identity, extra players, and joining after start. Unknown peers have a five-second handshake deadline; join attempts have a ten-second application deadline. Successful acknowledgment publishes exactly two roster slots. Changing duration clears both ready flags. Ready sets a boolean, so repeating it is idempotent.

Only a local host action can start. Both players must be accepted and ready. The host selects random roles, allocates the next match ID, and sends the reveal scene. Each peer acknowledges loading that scene; a 30-second timeout cancels to an unready lobby. After both acknowledgments, the host broadcasts the five-second reveal clock at 10 Hz. Both transition to the battlefield, and the host starts preparation. Network latency can delay the client's display by delivery time; the client never advances the authoritative timer independently.

## Messages

| Message | Sender | Channel / mode | Validation and result |
| --- | --- | --- | --- |
| hello(protocol, build, hash, name) | Client | 0 reliable | Matching content, name length, room capacity, phase |
| lobby_state(roster, name, duration, phase) | Host | 0 reliable | Authoritative readiness and room presentation |
| ready_request(bool) | Client or host local adapter | 0 reliable | Known peer, lobby only |
| begin_reveal / loaded(match_id) / reveal_clock / enter_battle | Host; client loading ack | 0 reliable | Known peer and phase; matching match ID; duplicate acks ignored |
| command(match_id, sequence, action, payload) | Client or host local adapter | 0 reliable | Membership, bounds, size/rate, replay, phase, role, node, funds, queue, allowed ability |
| command_ack(sequence, message) | Host | 0 reliable | Original result returned for remembered duplicate |
| snapshot(dictionary) | Host | 1 reliable, 10 Hz | Recipient-specific full state; old match/tick rejected |
| rematch(match_id) | Client or host local adapter | 0 reliable | Current results phase, unique vote from each roster member |

Host input passes through the same `_command_local` and `BattleSimulation.command` validation as client input. Sender identity comes from Godot's `get_remote_sender_id()`, never the payload. Clients submit intentions: `build {node:int}`, `train {}`, `ability {node:int, ability:String}`, `question {}`, `answer {answer:String}`, `surrender {}`. They cannot supply authoritative prices, balances, damage, cooldowns, outcomes, or rewards. Unknown actions fail.

Commands are limited to 40 per peer per second, 2048 serialized payload bytes, and 32 action characters. Sequence numbers must increase within a match. The last 512 combined command results are cached; older duplicate sequences are rejected. Cache lookup precedes terminal-state validation so a lost acknowledgment can be retried without another mutation. All command state is discarded on rematch/menu exit.

During play, snapshots contain only the recipient's wallet and active question. The defender receives no training queue. Question answer keys/explanations are never sent as open-question data; explanations appear after submission through acknowledgments. Final results expose both players' aggregate totals. Both players share the same local offline pack, so this is a privacy boundary for messages, not secrecy against someone inspecting their own files or a modified host.

## Discovery

Browsers bind an ephemeral UDP socket and send `CODEBORN_DISCOVER_1` once per second to broadcast and localhost. Hosts bind 24561 and reply to the observed sender address/port. Replies advertise name, accepted count, phase, gameplay port, protocol, content hash, and duration. Browsers validate bounded JSON packets (1024 bytes, 32 received packets per frame, at most 64 endpoints), deduplicate by observed IP/port, expire entries after five seconds, and disable full/in-progress/incompatible rows. Joining uses the observed source IP, never a claimed address inside JSON. Leaving the browser closes its socket. Hosts keep responding while full so unavailable sessions remain explained. Multiple adapters may show one host at multiple endpoints; manual interface selection is future work.

## Disconnect behavior

Before simulation exists, guest disconnection cancels loading/reveal and returns the host to an unready lobby. During preparation or active play, the host records an opponent-disconnected win exactly once. If the host disappears, the client returns to the browser with an interrupted/unverified connection-loss notice. A finished result is never overwritten. Both rematch votes are required; a departing opponent disables rematch. Menu exit closes sockets and releases all match state. No single delayed packet decides a loss.

The automated runner uses two real ENet processes on localhost. This does not validate hotspot discovery, firewall rules, sleep/resume, packet-loss performance, or any second machine. Those checks remain explicitly pending in the acceptance matrix.

Engine reference: [Godot 4.6 high-level multiplayer](https://docs.godotengine.org/en/4.6/tutorials/networking/high_level_multiplayer.html), [PacketPeerUDP](https://docs.godotengine.org/en/4.6/classes/class_packetpeerudp.html).
