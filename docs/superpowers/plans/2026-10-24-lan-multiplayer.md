# LAN Multiplayer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a local two-player lobby and synchronized match while preserving online play.

**Architecture:** A LanSession autoload uses ENet for peer messages and UDP for discovery. It implements the existing online session contract, allowing the host-authoritative match controller to run with either transport. The existing Developer panel layout supplies the new Play choice.

**Tech Stack:** Godot 4.7.2, GDScript, ENetMultiplayerPeer, PacketPeerUDP.

---

### Task 1: Menu routing

**Files:** `tests/ui/menu_layout_test.gd`, `scenes/codeborn_menu.tscn`, `scripts/codeborn_menu.gd`

- [ ] Update menu test so Play exposes Online Lobby and LAN Lobby buttons and validates their styling.
- [ ] Run the test and observe failure from the absent buttons.
- [ ] Replace the unused Play placeholder content with the Developer layout pattern and route each button.
- [ ] Run the test and verify both paths.

### Task 2: LAN session

**Files:** `scripts/network/lan_session.gd`, `project.godot`, `tests/network/lan_session_test.gd`

- [ ] Add a failing two-instance test for host, join, ready, match start, commands, snapshots, and disconnect.
- [ ] Run the test and observe failure from the absent service.
- [ ] Implement ENet host/guest protocol, version and sender checks, room readiness, match lifecycle, and UDP advertisement with direct-IP fallback.
- [ ] Run the test and fix protocol errors.

### Task 3: Lobby and match integration

**Files:** `scripts/ui/lan_lobby.gd`, `scenes/UI/lan_lobby.tscn`, `scripts/network/online_match.gd`, `scenes/network/lan_match.tscn`

- [ ] Add test expectations for direct-IP controls and LAN match routing, then observe failure.
- [ ] Connect the existing LAN lobby to LanSession and display host address, players, readiness, and actionable errors.
- [ ] Add a LAN match scene using the existing match controller, with transport-specific session, labels, and leave destination.
- [ ] Verify menu, lobby, and match tests plus a two-process local smoke test.

### Task 4: Final verification

**Files:** `docs/superpowers/specs/2026-10-24-lan-multiplayer-design.md`

- [ ] Run a Godot parse/import pass and all relevant tests.
- [ ] Review the diff for accidental online behavior or generated import changes.
- [ ] Record local two-process results and any device-only limits in the handoff.
