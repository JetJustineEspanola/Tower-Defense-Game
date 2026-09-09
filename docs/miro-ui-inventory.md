# Miro UI inventory and comparison status

Reference: https://miro.com/app/board/uXjVHq86R4M=/ . The board was inaccessible to the available tools on 2026-09-09; no claim of pixel or composition fidelity to the actual board is made. This inventory maps the explicit visual description supplied in the user request to the implemented screen skeleton. Review the real board before art/UI signoff.

The shared theme uses navy `#060920`/`#0d1830`, neon cyan `#68e3ff`, purple `#ab83ff`, and red `#ff627b` for defeat. Thin interface frames, corner brackets, stars, and concentric circuit arcs provide a restrained arcane-technology motif. Large CODE BORN branding anchors the centered vertical menu. Controls use containers and canvas scaling from 1366×768 to 1920×1080, with visible keyboard focus.

| Screen | Implemented controls and composition | Later review / deliberate difference |
| --- | --- | --- |
| Starting | Large centered branding; Play, Settings, Developer, Quit; quiet build footer | Procedural dark backdrop replaces detailed fantasy scenery; final logo pending |
| LAN browser | Central session list, refresh, selected join, host, IPv4 fallback, player name/port, Back, explanatory status | No interface selector or measured ping |
| Host lobby | Lobby title, two slots, ready status, host-only Start, duration, host addresses/copy, disconnect | Full cosmetic portraits and pack selection deferred |
| Role reveal | Large role, win condition, shared five-second countdown | Default cosmetic identity; loadout step deferred |
| Battlefield | Fixed isometric S route, core/portal, twelve nodes; top resources; bottom shop and upgrades; right Arcane panel; feedback line | Primitive models, static animation substitutes, no full roster cards |
| Victory/defeat | Cyan/red outcome heading, reason, core HP, elapsed time, economy/question/build/train/kill totals, rematch/menu | Decorative result artwork and animated celebration deferred |
| Settings | Master/music/effects, brightness, fullscreen, two target resolutions; immediate persistence | No rebinding/UI-scale selector; music/effects await assets |
| Developer | Editable JSON, add, validate, save; three question types and bounded rewards | Structured per-field editor, reviewed publish/archive/rollback later |

Input contract: UI calls MatchState.request and displays pending, accepted, or rejected text. Node selection happens only inside the battlefield SubViewport; clicking the sidebar/shop never sends a build action. Selection itself does not spend gold. Space/Enter activate focused controls; Tab moves focus. Mouse wheel or buttons adjust the camera within 0.85–1.15; rotation/pan remain fixed. Answers have their own text focus and there are no global purchase hotkeys.

The Arcane body scrolls when content is long. The core HP and timer stay outside it. Rematch disables while waiting for the other player's vote; disconnect disables it permanently for that result. A surrender dialog states the consequence while the match continues.

Generated evidence lives under ignored `tests/artifacts/`; selected reviewed screenshots are linked from the verification record. Synthetic presentation fixtures are labeled separately from real network test evidence. Intentional visual differences are not hidden as completed Miro acceptance.
