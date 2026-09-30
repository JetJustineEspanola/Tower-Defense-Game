# LAN browser and host lobby UI

Open scenes/ui/lan_lobby.tscn and press F6. Alternatively run scenes/codeborn_menu.tscn and click Play. The project's existing F5 startup remains the main map.

The browser has a player-name field, empty room state, Refresh, Join, Back and Host. Host opens a two-player room with the entered name, host readiness, waiting player slot, Start, Leave and sound settings. Start is disabled until both player slots are connected and ready. Join is disabled until an available room is selected.

This step is UI only, as requested. It does not discover, host or join network sessions, launch a multiplayer match, or invent remote players. Refresh explains that discovery is pending. The test supplies a guest temporarily to verify the ready and not-ready states; no guest is added during normal play.

All controls are saved in lan_lobby.tscn. Edit Header, Browser/Panel/Content, HostRoom/Panel/Content and SettingsOverlay. Background artwork is assets/ui/lobby/background.png. The cyan frame and network icon are separate SVG assets. Gameplay and player portraits remain separate images.

Future LAN integration: the UI emits host_requested, join_requested, leave_requested, readiness_changed and start_requested. Supply real data using set_rooms and set_guest, and handle connection errors and host departure in the connection layer. Keep gameplay start gated by host authority when networking is added.

The image-generation tool produced the background from the supplied LAN lobby reference using this prompt brief: background only, 16:9 anime fantasy night valley with floating cliffs, waterfalls, blue crystals and a glowing castle on the right; silver-haired chibi adventurer and robot cat at lower left; dark calm center for editable controls; no baked-in UI, lettering, logos or watermarks.

Checked in Godot 4.6: main menu Play transition, Host, player name display, readiness gating, settings open/close, Leave and Back. Browser and host layouts were rendered at 1366 × 768 for visual review.
