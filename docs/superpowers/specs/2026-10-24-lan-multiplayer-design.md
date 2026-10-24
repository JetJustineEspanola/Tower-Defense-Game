# LAN multiplayer design

Approved 2026-10-24. CodeBorn remains a two-player attacker/defender game.

## Flow

Play opens a two-button choice using the existing Developer panel and neon button styles. Online Lobby continues to the existing relay-backed room screen. LAN Lobby opens the existing LAN screen, now wired to a real local session. A host creates a room; a guest selects its UDP broadcast listing or types the host's local IPv4 address. The host IP is visible in the room. Both ready before host start.

## Transport and authority

Godot ENet carries lobby messages, reliable player actions, and host match snapshots over local Wi-Fi or a hotspot. UDP broadcast advertises rooms on the same subnet. Direct IP works when discovery is unavailable. A separate LanSession autoload implements the signal/method contract already consumed by online_match.gd. The host validates sender, role, match ID, request sequence, and readiness; it owns all simulation and results. The online relay and room client remain unchanged.

## Failure behavior

Connection attempts time out with a direct-IP hint. A failed host bind reports the port issue. A guest leaving before the match updates the host's player list and readiness. A host leaving closes the guest's room and match with an explicit message. The match ends on peer loss; there is no host migration or reconnect. Full and incompatible rooms reject the guest. Rematch swaps roles after both request it.

## Verification

Run menu and LAN service tests, Godot import/parse, and two local processes for host/join/start/action/snapshot/disconnect. Actual hotspot discovery and firewall behavior require two Windows devices on the same network.
