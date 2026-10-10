# Main Menu UI and Exported Lobby Layout

Date: 2026-10-10

## Goal

Bring Settings and Developer screens into the same visual language as the online room lobby, and fix the layout that becomes disordered after pressing Play in the exported Windows game.

## Current findings

- The main menu and Settings use custom offsets; the main menu container also has a manual scale. The Settings and Developer panels do not share one consistent layout and panel treatment.
- Developer has its own panel styling, while the lobby uses the navy and cyan frame, HUD theme, and anchored full-screen layout.
- Pressing Play changes directly to `scenes/UI/online_lobby.tscn`. That scene inherits the LAN lobby and applies the online room flow.
- Godot 4.7.2 is available. An export preset and Windows export templates were not found in the initial checks.
- The current `main` worktree has 479 modified files before implementation. Those changes are pre-existing and must be preserved.

## Design

Keep the existing main-menu video background and button artwork. Restyle the Settings and Developer panels with the lobby's navy panel, cyan frame, HUD theme, and consistent typography. Replace fixed offsets and manual scaling on the menu screens with centered, viewport-relative containers. Preserve existing controls and navigation, and connect the Settings volume slider to the master audio bus.

Investigate the Play-button issue by reproducing the current scene in the editor and comparing its layout with a Windows export. Identify and fix the source of the layout difference in the affected scene or project display configuration. Use the same viewport and anchoring rules in editor and exported builds.

Export a Windows `.exe` for review if templates can be installed for the available Godot version. Keep build output separate from source changes.

## Acceptance checks

- Settings and Developer panels use a consistent lobby-inspired style and remain centered at supported viewport sizes.
- Settings volume control changes master audio output.
- Play opens the online room lobby with the full-screen background, header, controls, and room panel arranged correctly.
- The editor run and exported `.exe` show the same lobby layout at the same viewport size.
- Only task-related source changes are added; pre-existing modifications are preserved.

## Scope limits

Do not redesign the lobby flow, add new settings, or change practice gameplay. Do not include generated import-cache files or the compiled executable in source control.
