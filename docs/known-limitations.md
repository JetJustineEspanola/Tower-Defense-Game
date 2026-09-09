# Known limitations and release risks

This is a playable foundation, not release-candidate signoff.

| Item | Consequence / next owner |
| --- | --- |
| Physical two-PC LAN/hotspot tests pending | Cannot accept M0 baseline or M1 shared gate; NET + QA record both devices, firewall/network, three consecutive matches |
| Actual Miro board unavailable to tools | Written visual direction implemented; UI + Jet compare against board before visual signoff |
| Full roster absent | One tower and one troop playable; other responsibility scenes are visual placeholders; GAME adds M2 mechanics |
| Phase Step reserved and disabled | Fifth Core Runner choice depends on guard blocking; GAME completes at M3 |
| Static procedural art; no bundled music/effects | Jet supplies GLBs/clips, QA/audio supplies licensed streams; existing buses/settings ready |
| Cosmetic loadout deferred | Reveal uses defaults and enters preparation; UI handles M5 loadout |
| Prototype question manager | JSON authoring supports add/edit/validate/save; no reviewed publication/archive, skip, difficulty picker, practice, or large curated bank |
| Reliable 10 Hz full snapshots | Correctness-first bounded graybox; slow/lossy networks can queue state; NET profiles and introduces movement channel/checkpoints in M6 |
| Discovery adapter ambiguity | Broadcast and localhost supported; virtual adapters can produce multiple endpoints; manual IPv4 fallback available |
| No reconnect or host migration | Confirmed disconnect ends/interrupts the session with a clear notice |
| No exported two-device/performance baseline | Actual integrated-GPU frame time and hardware budgets remain unmeasured |
| Balance not established | Prototype route is longer than plan; paired role-swapped human matches must tune income/range/speed |
| UI/control polish | No rebinding, independent UI scale, or controller support; keyboard focus and two specified resolutions covered |

High-priority release risks: economic snowballing, question attention cost, longer route balance, discovery/firewall behavior across adapters, and stale scene callbacks after future UI additions. Regression tests cover current authority/lifecycle invariants. A host-controlled LAN architecture is not protection against a modified host or local inspection of question answers.
