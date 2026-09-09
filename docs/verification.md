# Verification record — 2026-09-09

Build 0.1.0, protocol 1, Godot `4.6.stable.official.89cea1439`. Local environment: Windows 11 Home Single Language 10.0.26200; rendered checks used the NVIDIA GeForce RTX 4050 Laptop GPU with OpenGL 3.3 Compatibility (driver 596.49). An AMD Radeon 740M is also installed but was not the measured render device. No second PC, router, or hotspot was exercised.

## Completed checks

| Check | Evidence / result |
| --- | --- |
| Godot 4.6 editor import and script/scene loading | Clean headless editor import; all eight application scenes load; no parse errors |
| Rules and local settings | 44 assertions passed: transaction replay, wrong roles, invalid/occupied nodes, insufficient funds, training timing, resource privacy, frozen upgrade snapshots, two-slot cap, host answer validation, final-tick tie, terminal immutability, reset, duration clamp, settings save/reload |
| Rendered UI/navigation | 43 assertions passed; all starting buttons exercised (Quit in separate process); settings/developer/browser/lobby/game/results/menu loop; both role HUDs; both zoom limits; feedback stays within viewport |
| Two actual localhost processes | Host 9 / client 11 assertions passed; discover/join, repeated ready, matching roles, build/train, natural base-destruction outcome, rematch role swap, natural survival outcome, menu cleanup |
| Result comparison | Public final state and both players' wallet/stat totals match exactly between peers for both matches; private pending orders/questions excluded intentionally |
| Connection failures | 27 assertions passed across seven suites: content mismatch, full lobby, pre-ready start, ready reset after setting change, disconnect/rejoin before match, disconnect during match, host exit, unreachable host timeout |
| Windows export | Matching official 4.6.stable Windows x86_64 debug/release templates installed; debug export produced EXE/PCK; exported application launched with real rendering and exited with code 0, no script/runtime errors |
| Diff hygiene | `git diff --check` passed; generated caches, test artifacts and builds ignored |

Total: 134 test assertions, plus the separate Quit action and cross-peer final-state comparison. The final UI-only run followed the complete suite to verify the final label/role-preview changes. The Windows export was rebuilt afterward. There are no known parse errors or failing automated checks at handoff.

The integration harness accelerates wall-clock testing by feeding the same 1/30-second simulation ticks at about 30× speed. It does not assign winners or alter HP, prices, or results. The first match builds one tower and continuously orders troops; it ends at core destruction. The rematch makes no troop purchases and naturally reaches the configured 720-second survival limit. This proves authority/lifecycle behavior, not human balance or a real-time network endurance run.

The UI suite uses separately labeled synthetic presentation fixtures for battlefield and outcome screenshots. Those fixtures are not evidence of an actual human match. Rendered screenshots were inspected for route visibility, readable controls, sidebar/shop separation, result color, and resolution scaling. An early clipped feedback row and a stale results signal were fixed and retested.

Raw reproducible logs and all PNG captures are under ignored `tests/artifacts/`. Selected review images are committed in `docs/screenshots/`: [menu 1366](screenshots/menu-1366.png), [menu 1920](screenshots/menu-1920.png), [defender HUD 1366](screenshots/battle-defender-1366.png), [defender HUD 1920](screenshots/battle-defender-1920.png), [attacker HUD 1366](screenshots/battle-attacker-1366.png), [victory 1366](screenshots/victory-1366.png), [defeat 1366](screenshots/defeat-1366.png).

Windows build SHA-256:

```text
CodeBorn.exe  6566DD051E90D7AFBDAC9FB9AF901836FC662AB12BE16E06573C1ADB1CC85461
CodeBorn.pck  0AFB3D3E8E7496758DA923406CD66ACDE03227F8E56FFF2502644272A9BC59BB
```

The executable and PCK are a local handoff artifact under `builds/windows`. Export templates came from the official `godotengine/godot-builds` 4.6-stable release. Do not commit the build or templates to source control. Rebuilding after any code/data change changes the PCK hash.

## Physical LAN and review acceptance matrix

| Scenario | Required observation | Status |
| --- | --- | --- |
| Baseline export on PC A and PC B | Same build starts without editor; record OS/GPU/RAM and hashes | Pending second PC |
| Same Wi-Fi and hotspot | Discovery and manual IPv4 connect; record actual adapters/firewall/ports | Pending physical network |
| Three consecutive short paired matches | Both host-role arrangements, same outcomes/totals, safe return | Localhost covered; physical gate pending |
| Real-time 10–15 minute session | No progressive lag, missed orders, duplicate rewards, or stuck results | Pending human endurance run |
| Disconnect, sleep, adapter change | Clear interruption and fresh usable lobby; no fabricated client win | Basic process disconnect covered; sleep/network change pending |
| New tester journey | Join, ready, purchase, question, outcome, rematch without developer guidance | Automated controls covered; human QA pending |
| Miro visual comparison | Screen composition, silhouettes, HUD and result presentation reviewed against actual board | Board access unavailable; written direction only |
| Asset handoff | Jet/reviewer accept scale, pivots, sockets, animation substitutes and sample GLB | Primitive integration covered; authored import/team signoff pending |
| Curriculum and interface agreement | All five owners approve rules, contracts and beginner GDScript pack | Pending team review |

## GitHub milestone disposition

All existing M0/M1 issues #1–10 remain open. They explicitly require reviewer confirmation and shared milestone evidence that cannot be supplied by this one-PC session. The implementation PR provides progress for each:

- #1: style/asset contracts, palette, scene wrappers and inventory; team/art sample acceptance pending.
- #2: versioned rules/interfaces, stable IDs, economy/authority and typed simulation; team agreement pending.
- #3: pinned project, ports, export preset and running Windows build; second-PC/hardware record pending.
- #4: clickable screens, theme/focus, UI request/ack boundary and resolution captures; Miro/loadout and QA review pending.
- #5: defect template, curriculum baseline, author/reviewer checklist, risk and acceptance matrix; approval pending.
- #6: integrated primitive tower/troop/core/portal/S-route/twelve markers and documented static clips; art review/physical shared gate pending.
- #7: authoritative complete loop, preparation, training, combat, final-tick rule and duplicate protection; reviewed shared gate pending.
- #8: direct join/discovery, compatibility, replication, failure handling and export; three physical-PC matches pending.
- #9: working host/join/battle/results controls, private data presentation and purchase feedback; new-tester physical review pending.
- #10: automated acceptance evidence and recorded limits; physical two-PC demonstration still required.
