# CodeBorn five person team plan

Project: https://github.com/users/JetJustineEspanola/projects/1/views/2

This plan allocates work to five people. Jet Justine owns 3D art. The other four are proposed role assignments pending names and skills; they are not confirmed GitHub assignees. No project start date or weekly availability has been confirmed.

## Role distribution

| Person | Role | Main responsibility |
|---|---|---|
| Jet Justine | 3D Artist and Animation Owner | Models, rigs, animations, environment kit, materials, visual effects assets, optimized GLB delivery. Gameplay programming and final Godot scene integration belong to the programmers. |
| Member 2 pending name | Gameplay Programmer and Technical Lead | Combat, movement, economy, training, abilities, authoritative match rules, gameplay data and code review. |
| Member 3 pending name | LAN Programmer and Build Owner | ENet sessions, discovery, synchronization, network validation, match transitions, Windows exports and release integration. |
| Member 4 pending name | UI and Arcane Programmer | Menus, HUD, controls, settings, question runtime, question editor and local persistence. Works against the gameplay and network interfaces. |
| Member 5 pending name | QA Lead and Learning Content Owner | Test plans, question authoring, playtests, balance evidence, acceptance records, documentation and audio sourcing. Each programmer fixes defects in their system; QA does not own all fixes. |

## Schedule assumptions

Use a 16 week working plan plus up to 4 weeks of integration and delivery contingency. This is a reference schedule assuming roughly 25 to 30 available hours per person per week and three members able to program in Godot. It is not a promised release date. Week 1 starts only when the team agrees on kickoff. Reestimate after M1; a beginner team or lower weekly availability needs more time.

Keep roughly 20 percent of weekly capacity for reviews, integration and defects. The card estimates are provisional focused-work estimates, not a complete staffed calendar. Do not convert relative windows to calendar deadlines until hours and kickoff are confirmed. Splitting work among five people does not eliminate dependencies.

## Shared milestones

| Milestone | Target | Exit gate |
|---|---|---|
| M0 Scope and production setup | Week 1 | All five owners agree on the rules, interfaces, asset contract, target hardware, and a Windows baseline export. |
| M1 Playable LAN graybox | Weeks 2 to 3 | Two physical PCs complete a short direct IP match with one tower, one troop, base damage, a correct outcome, and safe menu return. |
| M2 Complete core roster | Weeks 4 to 5 | All six archetypes, guard rules, population caps, economy and two training lanes work together over LAN. |
| M3 Two of five abilities | Weeks 6 to 7 | All thirty abilities and sixty unordered pairs are checked; clients see the correct purchased and frozen squad upgrades. |
| M4 Arcane and developer tools | Weeks 8 to 9 | Three safe question formats, twenty seven reviewed test questions, mana costs, reward cap, pack validation and offline authoring work. |
| M5 Complete player journey | Weeks 10 to 11 | Browser discovery, lobby, readiness, reveal, loadout, settings, results and role swapped rematches work in an exported build. |
| M6 Content completion and balance | Weeks 12 to 14 | First map and roster art are final, 180 questions are reviewed, 40 paired playtest matches are recorded, and target hardware is measured. |
| M7 Release candidate | Weeks 15 to 16 | Supported LAN setups, clean machine export, full load performance and two hour repeated match soak pass with no blocking defects. |

## Milestone ownership matrix

| Milestone | Jet 3D art | Gameplay | LAN and builds | UI and Arcane | QA and content |
|---|---|---|---|---|---|
| M0 | Define chibi style and asset delivery contract | Freeze match rules and gameplay interfaces | Prepare pinned Godot project and Windows build | Design screens and draft HUD interaction | Set acceptance plan and question curriculum |
| M1 | Deliver importable graybox battle assets | Build the authoritative short match loop | Connect two PCs and replicate the graybox match | Connect minimum host join and battle controls | Verify the first complete two PC match |
| M2 | Model all six archetypes and guard | Implement full roster economy and continuous training | Synchronize the complete battle state | Complete role shops queues and inspectors | Test roster rules and establish balance baseline |
| M3 | Finish key animations and ability effect assets | Implement all thirty abilities and modifier rules | Replicate upgrades and protect purchase transactions | Build two slot upgrade selection and feedback | Audit ability matrix and counterplay |
| M4 | Finish battle materials and first map art pass | Integrate Arcane rewards with simulation economy | Synchronize private questions and pack compatibility | Build Arcane runtime and offline authoring tool | Review test pack and test question lifecycle |
| M5 | Finalize the first playable environment | Finalize match phases and rematch resets | Deliver LAN discovery lobby and synchronized flow | Polish menus settings loadout and results | Validate complete journey and curate audio |
| M6 | Optimize and freeze release art | Tune balance using paired match evidence | Test adverse networks and optimize replication | Finish accessibility content scale and polish | Publish question bank and run forty balance matches |
| M7 | Sign off final art package and credits | Close gameplay blockers and freeze rules | Build and verify the Windows release candidate | Close interface blockers and finalize help | Run final release gate and archive evidence |

## Workload estimates

| Role | Focused hours across cards | Planned work packages |
|---|---:|---:|
| 3D Artist and Animation Owner | 182 | 8 |
| Gameplay Programmer and Technical Lead | 220 | 8 |
| LAN Programmer and Build Owner | 214 | 8 |
| UI and Arcane Programmer | 212 | 8 |
| QA Lead and Learning Content Owner | 226 | 8 |

The dedicated QA and content owner prepares and validates tests; developers fix defects in their own systems. Independent question review is shared with GAME and UI. UI owns the 2D interface icon system and audio integration; Jet provides 3D models, animations and optional renders. QA sources audio and maintains credits. These handoffs prevent 3D art from becoming the default owner of every visual or audio task.

## Board setup and workflow

Keep the existing Board, Roadmap, My items and Backlog views. Use 40 milestone work packages, eight per role, with explicit checklist tasks below. Add a Role field and a Phase field if they do not exist. Use Estimate for focused hours only if the existing field has no conflicting meaning. Preserve existing project data and settings.

Place only the five M0 cards in Todo initially. Keep later cards in Backlog or with no Status if the project has no Backlog option. Keep at most one active card per person and no more than five team cards In progress. A milestone card may contain several checklists, but should be split into smaller child tasks if it cannot be reviewed incrementally. A card is Done only when its role deliverable and required integration checks pass.

Native GitHub repository Milestones require a confirmed repository. Until one is selected, milestone IDs M0 to M7 and the project Phase field identify the release gates; do not pretend a project draft card is a repository Milestone. Jet can be assigned after access is confirmed; leave other assignees empty until their usernames are supplied.

Roadmap date fields remain unset until kickoff is known. Group by Phase to review releases and filter by Role for personal work. If saved views cannot be created, use the role and milestone prefixes already present in every title.

## Team cadence and handoffs

Monday: each person selects one ready work package and flags missing inputs. Midweek: integrate code, assets and content into a versioned Windows build. Friday: run a two PC demonstration and record progress against the shared gate. A milestone passes only after the required roles complete their deliveries and QA records the gate result.

ART hands off source files plus GLB exports, texture files, named clips, dimensions and a preview. GAME checks the import and owns scene wiring. NET supplies versioned exports and reproduction context. UI supplies usable screens and question tooling. QA hands off reviewed content records, defect reports and acceptance evidence. Never mark a dependency complete solely because someone sent a file.

Critical path: M0 contracts > M1 direct IP match > M2 full roster > M3 ability composition > M4 question integration > M5 complete flow > M6 evidence based tuning > M7 release gate. Art and question drafting proceed alongside these dependencies.

## Detailed work packages

### [M0-ART] Define chibi style and asset delivery contract

## Responsibility
Owner: Jet Justine — 3D Artist and Animation Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M0 — Scope and production setup
Target window: Week 1 from agreed kickoff; no calendar deadline committed.
Estimate: 10 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Create one style sheet for futuristic fantasy chibi proportions, palette, silhouettes and material limits.
- [ ] Agree with GAME on world scale, ground pivot, forward axis, tower footprint and socket names.
- [ ] Define the GLB naming and folder rules, animation names, texture formats and initial budgets.
- [ ] List the 3 towers, 3 bugs, guard, core, portal, map kit and priority effects.

## Dependencies
None. Start during kickoff.
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Style sheet, asset inventory and import contract accepted by GAME; one sample imports at correct scale.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All five owners agree on the rules, interfaces, asset contract, target hardware, and a Windows baseline export.

Planning ID: M0-ART


### [M0-GAME] Freeze match rules and gameplay interfaces

## Responsibility
Owner: Member 2 pending name — Gameplay Programmer and Technical Lead
Reviewer: LAN Programmer and Build Owner
Milestone: M0 — Scope and production setup
Target window: Week 1 from agreed kickoff; no calendar deadline committed.
Estimate: 14 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Resolve the 12 minute timer, final tick tie, preparation rules and role permissions.
- [ ] Freeze training snapshots, two ability ownership rules, guard release immunity and economy caps.
- [ ] Define stable archetype, entity, node and command IDs with NET and UI.
- [ ] Create repository structure and typed gameplay data skeleton; agree on review and branch rules.

## Dependencies
None. Start during kickoff.
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Versioned rules and interface sheet exist; no unresolved blocker prevents the graybox match.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All five owners agree on the rules, interfaces, asset contract, target hardware, and a Windows baseline export.

Planning ID: M0-GAME


### [M0-NET] Prepare pinned Godot project and Windows build

## Responsibility
Owner: Member 3 pending name — LAN Programmer and Build Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M0 — Scope and production setup
Target window: Week 1 from agreed kickoff; no calendar deadline committed.
Estimate: 12 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Pin a tested Godot 4.6 patch and matching export templates.
- [ ] Establish project folders, build version and protocol version policy with GAME.
- [ ] Produce a minimal Windows x86_64 export and run it on two physical PCs.
- [ ] Record both test machines and router or hotspot; reserve the proposed gameplay and discovery ports.

## Dependencies
None. Start during kickoff.
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Both machines run the same versioned baseline build without the editor.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All five owners agree on the rules, interfaces, asset contract, target hardware, and a Windows baseline export.

Planning ID: M0-NET


### [M0-UI] Design screens and draft HUD interaction

## Responsibility
Owner: Member 4 pending name — UI and Arcane Programmer
Reviewer: QA Lead and Learning Content Owner
Milestone: M0 — Scope and production setup
Target window: Week 1 from agreed kickoff; no calendar deadline committed.
Estimate: 12 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Wireframe menu, LAN browser, lobby, role reveal, loadout, HUD, Arcane sidebar and results.
- [ ] Define input focus, purchase feedback and unavailable action explanations.
- [ ] Agree with GAME and NET on UI request and acknowledgment events.
- [ ] Set up UI theme, keyboard focus and small screen layout prototype.

## Dependencies
None. Start during kickoff.
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Clickable screen skeleton and interface contract reviewed by QA at 1366 by 768.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All five owners agree on the rules, interfaces, asset contract, target hardware, and a Windows baseline export.

Planning ID: M0-UI


### [M0-QA] Set acceptance plan and question curriculum

## Responsibility
Owner: Member 5 pending name — QA Lead and Learning Content Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M0 — Scope and production setup
Target window: Week 1 from agreed kickoff; no calendar deadline committed.
Estimate: 12 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Create defect template with build, role, steps, expected result and evidence.
- [ ] Write the initial LAN, transactions, outcomes and lifecycle test matrix.
- [ ] Confirm GDScript beginner pack or document the proposed replacement language for team decision.
- [ ] Create question author and reviewer checklist and a release risk log.

## Dependencies
None. Start during kickoff.
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Test matrix, curriculum decision and review checklist approved; no unsupported language mix.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All five owners agree on the rules, interfaces, asset contract, target hardware, and a Windows baseline export.

Planning ID: M0-QA


### [M1-ART] Deliver importable graybox battle assets

## Responsibility
Owner: Jet Justine — 3D Artist and Animation Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M1 — Playable LAN graybox
Target window: Weeks 2 to 3 from agreed kickoff; no calendar deadline committed.
Estimate: 18 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Deliver a simple Pulse Spire, Core Runner, base and portal at agreed scale.
- [ ] Provide the flat S route map blockout and twelve placeholder deployment markers.
- [ ] Include basic idle, movement and attack placeholder clips or documented static substitutes.
- [ ] Check silhouettes from the fixed isometric camera with UI and GAME.

## Dependencies
M0-ART, M0-GAME
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
GAME imports the assets without scale or pivot corrections; they do not hide the route.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Two physical PCs complete a short direct IP match with one tower, one troop, base damage, a correct outcome, and safe menu return.

Planning ID: M1-ART


### [M1-GAME] Build the authoritative short match loop

## Responsibility
Owner: Member 2 pending name — Gameplay Programmer and Technical Lead
Reviewer: LAN Programmer and Build Owner
Milestone: M1 — Playable LAN graybox
Target window: Weeks 2 to 3 from agreed kickoff; no calendar deadline committed.
Estimate: 30 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Implement host tick, wallet, one legal deployment node and one tower.
- [ ] Implement one troop order, route progress, target selection, damage and base contact.
- [ ] Implement preparation, active phase, terminal state and final tick tie rule.
- [ ] Expose validated commands to NET and state events to UI; include duplicate spend protection.

## Dependencies
M0-GAME, M0-NET
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
The same simulation finishes a debug short match and applies each purchase and outcome once.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Two physical PCs complete a short direct IP match with one tower, one troop, base damage, a correct outcome, and safe menu return.

Planning ID: M1-GAME


### [M1-NET] Connect two PCs and replicate the graybox match

## Responsibility
Owner: Member 3 pending name — LAN Programmer and Build Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M1 — Playable LAN graybox
Target window: Weeks 2 to 3 from agreed kickoff; no calendar deadline committed.
Estimate: 30 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Create host and direct IPv4 join for one remote client.
- [ ] Validate version and identity; keep network host separate from gameplay role.
- [ ] Route both players through host command validation and replicate entities, HP and wallets.
- [ ] Handle failed join and disconnect; export a shared two PC test build.

## Dependencies
M0-NET, M0-GAME
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Three consecutive short matches complete on two PCs with identical outcome and totals.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Two physical PCs complete a short direct IP match with one tower, one troop, base damage, a correct outcome, and safe menu return.

Planning ID: M1-NET


### [M1-UI] Connect minimum host join and battle controls

## Responsibility
Owner: Member 4 pending name — UI and Arcane Programmer
Reviewer: QA Lead and Learning Content Owner
Milestone: M1 — Playable LAN graybox
Target window: Weeks 2 to 3 from agreed kickoff; no calendar deadline committed.
Estimate: 24 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Build functional Play, host, direct join and Back actions.
- [ ] Display base HP, timer, role, gold and basic shop cards.
- [ ] Show pending purchase, acknowledgment and failure reason.
- [ ] Connect result and menu return; prevent UI clicks reaching battlefield placement.

## Dependencies
M0-UI, M0-GAME, M0-NET
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
A new tester can join, purchase and finish the short match without developer controls.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Two physical PCs complete a short direct IP match with one tower, one troop, base damage, a correct outcome, and safe menu return.

Planning ID: M1-UI


### [M1-QA] Verify the first complete two PC match

## Responsibility
Owner: Member 5 pending name — QA Lead and Learning Content Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M1 — Playable LAN graybox
Target window: Weeks 2 to 3 from agreed kickoff; no calendar deadline committed.
Estimate: 22 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Execute direct IP tests on two physical PCs and both host gameplay roles.
- [ ] Check insufficient gold, duplicate command and occupied node handling.
- [ ] Test base destruction, timer win, host exit and menu cleanup.
- [ ] Record defects, retest fixes and capture the M1 acceptance demonstration.

## Dependencies
M1-GAME, M1-NET, M1-UI
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
M1 shared gate passes; failures have reproducible reports, not verbal-only signoff.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Two physical PCs complete a short direct IP match with one tower, one troop, base damage, a correct outcome, and safe menu return.

Planning ID: M1-QA


### [M2-ART] Model all six archetypes and guard

## Responsibility
Owner: Jet Justine — 3D Artist and Animation Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M2 — Complete core roster
Target window: Weeks 4 to 5 from agreed kickoff; no calendar deadline committed.
Estimate: 28 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Model Pulse Spire, Mana Mint and Sentinel Gate with distinct silhouettes.
- [ ] Model Breach Beetle, Cache Mite and Core Runner plus the guard.
- [ ] Prepare reusable rigs or compatible animation structure for the bug family.
- [ ] Export block color GLBs and verify all game sockets with GAME.

## Dependencies
M1-ART
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Seven unit and tower assets plus their sources are delivered and imported correctly.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All six archetypes, guard rules, population caps, economy and two training lanes work together over LAN.

Planning ID: M2-ART


### [M2-GAME] Implement full roster economy and continuous training

## Responsibility
Owner: Member 2 pending name — Gameplay Programmer and Technical Lead
Reviewer: LAN Programmer and Build Owner
Milestone: M2 — Complete core roster
Target window: Weeks 4 to 5 from agreed kickoff; no calendar deadline committed.
Estimate: 36 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Implement all six data driven archetypes and ordinary attack behavior.
- [ ] Implement two training lanes, shared queue, reserved population and frozen order data.
- [ ] Implement guards with bounded blocking and global immunity; add Cache Mite escort and lifetime rules.
- [ ] Implement baseline income, Mint and Mite income, caps, sale and cancellation refunds.
- [ ] Integrate ART assets through stable scene wrappers without changing simulation ownership.

## Dependencies
M1-GAME, M1-NET
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Every category plays its intended role; no infinite block, negative wallet or population overflow.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All six archetypes, guard rules, population caps, economy and two training lanes work together over LAN.

Planning ID: M2-GAME


### [M2-NET] Synchronize the complete battle state

## Responsibility
Owner: Member 3 pending name — LAN Programmer and Build Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M2 — Complete core roster
Target window: Weeks 4 to 5 from agreed kickoff; no calendar deadline committed.
Estimate: 30 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Replicate all roster types, guard ownership, reserved population and training completion events.
- [ ] Keep the opponent training queue and wallets private.
- [ ] Add snapshot sequence checks, stable entity IDs and reliable critical events.
- [ ] Enforce role permissions and reject invalid node, blueprint or entity IDs.

## Dependencies
M1-NET, M2-GAME
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Both clients remain consistent during a full roster stress match and malformed commands are rejected.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All six archetypes, guard rules, population caps, economy and two training lanes work together over LAN.

Planning ID: M2-NET


### [M2-UI] Complete role shops queues and inspectors

## Responsibility
Owner: Member 4 pending name — UI and Arcane Programmer
Reviewer: QA Lead and Learning Content Owner
Milestone: M2 — Complete core roster
Target window: Weeks 4 to 5 from agreed kickoff; no calendar deadline committed.
Estimate: 28 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Add all three cards for each role with correct cost, count and training information.
- [ ] Show two training lanes, queued snapshots and live plus reserved population.
- [ ] Add tower placement, cancel, sale and selection inspector workflows.
- [ ] Show health, armor, range and relevant category specific attributes.

## Dependencies
M1-UI, M2-GAME
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Every legal purchase is usable; every rejected action has a clear reason and no accidental charge.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All six archetypes, guard rules, population caps, economy and two training lanes work together over LAN.

Planning ID: M2-UI


### [M2-QA] Test roster rules and establish balance baseline

## Responsibility
Owner: Member 5 pending name — QA Lead and Learning Content Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M2 — Complete core roster
Target window: Weeks 4 to 5 from agreed kickoff; no calendar deadline committed.
Estimate: 28 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Run guard immunity, economy death tick, simultaneous training completion and refund tests.
- [ ] Record early economy rush and pure siege or objective strategies.
- [ ] Check every legal node is reachable by siege and cannot change the route.
- [ ] Begin question drafts: prepare twenty seven records across the nine format and difficulty combinations.

## Dependencies
M2-GAME, M2-NET, M2-UI
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Core roster regression suite passes and baseline balance observations are stored with the build version.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All six archetypes, guard rules, population caps, economy and two training lanes work together over LAN.

Planning ID: M2-QA


### [M3-ART] Finish key animations and ability effect assets

## Responsibility
Owner: Jet Justine — 3D Artist and Animation Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M3 — Two of five abilities
Target window: Weeks 6 to 7 from agreed kickoff; no calendar deadline committed.
Estimate: 28 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Deliver idle, walk, attack, damage and death states for bugs and guard as applicable.
- [ ] Add clear tower firing, economy payout and guard spawning animations.
- [ ] Deliver restrained effect assets for slow, splash, forked hit, plating and phase feedback.
- [ ] Check effects are readable with several troops on screen and do not obscure targets.

## Dependencies
M2-ART, M2-GAME
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Animations and effect assets are imported, named consistently and previewed at battle camera scale.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All thirty abilities and sixty unordered pairs are checked; clients see the correct purchased and frozen squad upgrades.

Planning ID: M3-ART


### [M3-GAME] Implement all thirty abilities and modifier rules

## Responsibility
Owner: Member 2 pending name — Gameplay Programmer and Technical Lead
Reviewer: LAN Programmer and Build Owner
Milestone: M3 — Two of five abilities
Target window: Weeks 6 to 7 from agreed kickoff; no calendar deadline committed.
Estimate: 36 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Implement the five ability definitions for each of the six archetypes.
- [ ] Enforce two distinct choices, slot pricing, permanent selection and no duplicate spending.
- [ ] Apply tower changes per instance and troop blueprint changes only to future purchases.
- [ ] Define secondary effect restrictions, timer progress preservation and health percentage preservation.
- [ ] Add deterministic tests for every single ability and all sixty unordered pairs.

## Dependencies
M2-GAME
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
All 30 singles and 60 pairs pass rule tests, including reversed purchase order where applicable.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All thirty abilities and sixty unordered pairs are checked; clients see the correct purchased and frozen squad upgrades.

Planning ID: M3-GAME


### [M3-NET] Replicate upgrades and protect purchase transactions

## Responsibility
Owner: Member 3 pending name — LAN Programmer and Build Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M3 — Two of five abilities
Target window: Weeks 6 to 7 from agreed kickoff; no calendar deadline committed.
Estimate: 26 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Add validated ability purchase commands and idempotent responses.
- [ ] Publish blueprint upgrade choices and the actual frozen abilities of deployed squads.
- [ ] Reject third choice, duplicate ability, stale match and unauthorized owner requests.
- [ ] Check checkpoints include derived stats and effect expiry ticks.

## Dependencies
M2-NET, M3-GAME
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Host and joining player see the same correct abilities; retries never charge twice.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All thirty abilities and sixty unordered pairs are checked; clients see the correct purchased and frozen squad upgrades.

Planning ID: M3-NET


### [M3-UI] Build two slot upgrade selection and feedback

## Responsibility
Owner: Member 4 pending name — UI and Arcane Programmer
Reviewer: QA Lead and Learning Content Owner
Milestone: M3 — Two of five abilities
Target window: Weeks 6 to 7 from agreed kickoff; no calendar deadline committed.
Estimate: 28 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Show all five choices with effect, price and before or after statistics.
- [ ] Confirm permanent selection with clear wording and show both occupied slots.
- [ ] Label troop changes Future orders only and show icons on queued orders.
- [ ] Use consistent temporary icons; coordinate any 2D icons with QA rather than assigning them to 3D art by default.

## Dependencies
M2-UI, M3-GAME
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Both roles can compare and purchase abilities; existing squads are never visually relabeled as upgraded.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All thirty abilities and sixty unordered pairs are checked; clients see the correct purchased and frozen squad upgrades.

Planning ID: M3-UI


### [M3-QA] Audit ability matrix and counterplay

## Responsibility
Owner: Member 5 pending name — QA Lead and Learning Content Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M3 — Two of five abilities
Target window: Weeks 6 to 7 from agreed kickoff; no calendar deadline committed.
Estimate: 32 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Run and record the 30 single and 60 pair acceptance cases.
- [ ] Check fork plus splash, increased guard cap, Mite economy pair and four Runner core damage cases.
- [ ] Test all two slot failure paths and snapshot boundaries.
- [ ] Record purchase rates and obvious mandatory or useless choices for later balance changes.

## Dependencies
M3-GAME, M3-NET, M3-UI
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Pair checklist is complete; no reproducible recursive hit, third slot or upgraded old squad defect remains.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
All thirty abilities and sixty unordered pairs are checked; clients see the correct purchased and frozen squad upgrades.

Planning ID: M3-QA


### [M4-ART] Finish battle materials and first map art pass

## Responsibility
Owner: Jet Justine — 3D Artist and Animation Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M4 — Arcane and developer tools
Target window: Weeks 8 to 9 from agreed kickoff; no calendar deadline committed.
Estimate: 26 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Texture and material the three towers, three bugs, guard, base and portal.
- [ ] Build reusable route edging and small environment props within agreed budgets.
- [ ] Keep deployment nodes and route silhouettes clearly visible under the camera.
- [ ] Deliver final source files and material atlas or texture set documentation.

## Dependencies
M3-ART
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
All battle models have a consistent first final material pass and import without missing textures.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Three safe question formats, twenty seven reviewed test questions, mana costs, reward cap, pack validation and offline authoring work.

Planning ID: M4-ART


### [M4-GAME] Integrate Arcane rewards with simulation economy

## Responsibility
Owner: Member 2 pending name — Gameplay Programmer and Technical Lead
Reviewer: LAN Programmer and Build Owner
Milestone: M4 — Arcane and developer tools
Target window: Weeks 8 to 9 from agreed kickoff; no calendar deadline committed.
Estimate: 22 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Expose authoritative mana spending and rolling sixty second gold allowance to question runtime.
- [ ] Ensure failed generation, skip and duplicate answers cannot mutate resources incorrectly.
- [ ] Define question command contracts and terminal match behavior with UI and NET.
- [ ] Review the question evaluator to ensure submitted code is never executed.

## Dependencies
M3-GAME, M0-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Mana, reward cap, answer settlement and end of match transactions pass deterministic tests.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Three safe question formats, twenty seven reviewed test questions, mana costs, reward cap, pack validation and offline authoring work.

Planning ID: M4-GAME


### [M4-NET] Synchronize private questions and pack compatibility

## Responsibility
Owner: Member 3 pending name — LAN Programmer and Build Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M4 — Arcane and developer tools
Target window: Weeks 8 to 9 from agreed kickoff; no calendar deadline committed.
Estimate: 24 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Compare published pack IDs and hashes before readying a match.
- [ ] Send private question instances only to their owner; never send answer keys as gameplay payloads.
- [ ] Validate question IDs, message lengths and repeated submissions.
- [ ] Test absent, mismatched and corrupt packs without attempting arbitrary remote file loading.

## Dependencies
M3-NET, M4-GAME, M4-UI
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Both peers reject incompatible packs and question retries settle exactly once.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Three safe question formats, twenty seven reviewed test questions, mana costs, reward cap, pack validation and offline authoring work.

Planning ID: M4-NET


### [M4-UI] Build Arcane runtime and offline authoring tool

## Responsibility
Owner: Member 4 pending name — UI and Arcane Programmer
Reviewer: QA Lead and Learning Content Owner
Milestone: M4 — Arcane and developer tools
Target window: Weeks 8 to 9 from agreed kickoff; no calendar deadline committed.
Estimate: 38 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Implement multiple choice, identification and constrained Coding Fix without evaluating user code.
- [ ] Add Generate, Submit, Skip, explanation, draft retention, focus and mana feedback.
- [ ] Implement offline add, edit, preview, validate, import, export, archive and publish workflows.
- [ ] Save drafts and immutable pack versions atomically with backup; disable authoring in sessions.
- [ ] Integrate the twenty seven reviewed test questions and exact normalization policy.

## Dependencies
M3-UI, M0-QA, M4-GAME
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
All three formats and developer CRUD workflow function offline with correct data validation and recovery.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Three safe question formats, twenty seven reviewed test questions, mana costs, reward cap, pack validation and offline authoring work.

Planning ID: M4-UI


### [M4-QA] Review test pack and test question lifecycle

## Responsibility
Owner: Member 5 pending name — QA Lead and Learning Content Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M4 — Arcane and developer tools
Target window: Weeks 8 to 9 from agreed kickoff; no calendar deadline committed.
Estimate: 32 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Review all twenty seven test questions and accepted answers with a programmer as second reviewer.
- [ ] Test type shuffling, option IDs, answer case rules, cap, skip timing and pool exhaustion.
- [ ] Test malformed files, missing explanations, invalid enums, draft packs and duplicate IDs.
- [ ] Verify typing never buys units and important battle alarms remain visible or audible.

## Dependencies
M2-QA, M4-UI, M4-GAME, M4-NET
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
All nine type and difficulty groups have reviewed questions and lifecycle tests pass.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Three safe question formats, twenty seven reviewed test questions, mana costs, reward cap, pack validation and offline authoring work.

Planning ID: M4-QA


### [M5-ART] Finalize the first playable environment

## Responsibility
Owner: Jet Justine — 3D Artist and Animation Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M5 — Complete player journey
Target window: Weeks 10 to 11 from agreed kickoff; no calendar deadline committed.
Estimate: 26 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Complete the map environment, node markers, base, portal and decorative props.
- [ ] Check occlusion at both zoom limits and all supported sidebar layouts.
- [ ] Deliver final effect timing hooks and optimize unnecessary materials or textures.
- [ ] Provide consistent turntable renders for UI card artwork if needed; UI owns layout and icons.

## Dependencies
M4-ART, M2-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
The complete art set reads clearly in an exported match and every node remains selectable.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Browser discovery, lobby, readiness, reveal, loadout, settings, results and role swapped rematches work in an exported build.

Planning ID: M5-ART


### [M5-GAME] Finalize match phases and rematch resets

## Responsibility
Owner: Member 2 pending name — Gameplay Programmer and Technical Lead
Reviewer: LAN Programmer and Build Owner
Milestone: M5 — Complete player journey
Target window: Weeks 10 to 11 from agreed kickoff; no calendar deadline committed.
Estimate: 24 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Finish preparation, role rules, surrender, results totals and final tick resolution.
- [ ] Ensure all per match systems, cooldowns, entities and wallets reset cleanly.
- [ ] Support cosmetic loadout defaults without adding new hero abilities.
- [ ] Resolve simulation defects found in complete user journey testing.

## Dependencies
M4-GAME, M3-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Repeated role swapped matches retain no state and produce correct result reasons.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Browser discovery, lobby, readiness, reveal, loadout, settings, results and role swapped rematches work in an exported build.

Planning ID: M5-GAME


### [M5-NET] Deliver LAN discovery lobby and synchronized flow

## Responsibility
Owner: Member 3 pending name — LAN Programmer and Build Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M5 — Complete player journey
Target window: Weeks 10 to 11 from agreed kickoff; no calendar deadline committed.
Estimate: 36 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Implement bounded discovery request and response, entry expiry and interface selection.
- [ ] Complete two ready states, host Start, setting change resets and duplicate Start protection.
- [ ] Coordinate five second reveal, loadout timeout, load acknowledgment and preparation start.
- [ ] Implement explicit timeout and host disappearance results; keep direct IP fallback.
- [ ] Package connection guidance for firewall, isolation and hotspot limitations.

## Dependencies
M4-NET, M1-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Full host or join to results and rematch flow works on tested LAN setups.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Browser discovery, lobby, readiness, reveal, loadout, settings, results and role swapped rematches work in an exported build.

Planning ID: M5-NET


### [M5-UI] Polish menus settings loadout and results

## Responsibility
Owner: Member 4 pending name — UI and Arcane Programmer
Reviewer: QA Lead and Learning Content Owner
Milestone: M5 — Complete player journey
Target window: Weeks 10 to 11 from agreed kickoff; no calendar deadline committed.
Estimate: 32 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Finish Starting Screen Play, Settings, Developer and Quit behavior.
- [ ] Finish LAN list, readiness, reveal, cosmetic loadout and loading displays.
- [ ] Implement brightness, volume buses, window mode, UI scale, bindings and settings persistence.
- [ ] Finish results by role, rematch acceptance and connection recovery screens.
- [ ] Integrate sourced audio and show a useful explanation for every disabled action.

## Dependencies
M4-UI, M5-GAME, M5-NET
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
All screens and saved settings work in the exported build at both target resolutions.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Browser discovery, lobby, readiness, reveal, loadout, settings, results and role swapped rematches work in an exported build.

Planning ID: M5-UI


### [M5-QA] Validate complete journey and curate audio

## Responsibility
Owner: Member 5 pending name — QA Lead and Learning Content Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M5 — Complete player journey
Target window: Weeks 10 to 11 from agreed kickoff; no calendar deadline committed.
Estimate: 28 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Run every menu and match transition, including return paths and canceled starts.
- [ ] Check keyboard focus, UI scale, reduced effects and text at target resolutions.
- [ ] Source licensed music and event sounds, maintain credits, and hand off implementation to UI.
- [ ] Finish a batch of ninety reviewed questions and record second reviewer signoff.

## Dependencies
M5-GAME, M5-NET, M5-UI, M5-ART
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Complete journey checklist passes; audio rights and ninety reviewed content records are ready.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Browser discovery, lobby, readiness, reveal, loadout, settings, results and role swapped rematches work in an exported build.

Planning ID: M5-QA


### [M6-ART] Optimize and freeze release art

## Responsibility
Owner: Jet Justine — 3D Artist and Animation Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M6 — Content completion and balance
Target window: Weeks 12 to 14 from agreed kickoff; no calendar deadline committed.
Estimate: 30 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Fix art defects from real playtests and reduce measured material or effect bottlenecks.
- [ ] Verify all animation clips, pivots, transforms, texture imports and missing references.
- [ ] Finish any essential visual feedback; reject optional expansion assets for this release.
- [ ] Freeze a versioned art package with source files, exports and source or license records.

## Dependencies
M5-ART, M5-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Maximum load test shows readable assets within the recorded device budget and no missing resources.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
First map and roster art are final, 180 questions are reviewed, 40 paired playtest matches are recorded, and target hardware is measured.

Planning ID: M6-ART


### [M6-GAME] Tune balance using paired match evidence

## Responsibility
Owner: Member 2 pending name — Gameplay Programmer and Technical Lead
Reviewer: LAN Programmer and Build Owner
Milestone: M6 — Content completion and balance
Target window: Weeks 12 to 14 from agreed kickoff; no calendar deadline committed.
Estimate: 34 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Tune costs, income, training, HP and damage against build labeled match results.
- [ ] Address economy rushes, dead choices and unavoidable early defeats with small documented changes.
- [ ] Profile simulation and target queries under all legal entities.
- [ ] Fix defects without expanding roster, map rules or manual spell scope.

## Dependencies
M5-GAME, M5-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Balance changes have before and after evidence; all gameplay regression tests still pass.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
First map and roster art are final, 180 questions are reviewed, 40 paired playtest matches are recorded, and target hardware is measured.

Planning ID: M6-GAME


### [M6-NET] Test adverse networks and optimize replication

## Responsibility
Owner: Member 3 pending name — LAN Programmer and Build Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M6 — Content completion and balance
Target window: Weeks 12 to 14 from agreed kickoff; no calendar deadline committed.
Estimate: 30 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Test supported router and hotspot setups, broadcast failure and direct IP fallback.
- [ ] Exercise 100 ms round trip and 2 percent loss test conditions where tooling allows.
- [ ] Measure bandwidth, checkpoint recovery, delayed commands and stale snapshot handling.
- [ ] Test sleep, Wi Fi change, host exit and port conflicts; record supported setups.

## Dependencies
M5-NET, M5-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
No divergent outcome or duplicate currency occurs across the supported network test matrix.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
First map and roster art are final, 180 questions are reviewed, 40 paired playtest matches are recorded, and target hardware is measured.

Planning ID: M6-NET


### [M6-UI] Finish accessibility content scale and polish

## Responsibility
Owner: Member 4 pending name — UI and Arcane Programmer
Reviewer: QA Lead and Learning Content Owner
Milestone: M6 — Content completion and balance
Target window: Weeks 12 to 14 from agreed kickoff; no calendar deadline committed.
Estimate: 28 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Integrate the full published 180 question bank and test realistic long prompts.
- [ ] Fix layout at 1366 by 768 and 1920 by 1080 with each supported UI scale.
- [ ] Complete 30 legible ability icons using an agreed simple 2D system.
- [ ] Polish tutorial hints, audio priorities and recovery messages without hiding battle state.

## Dependencies
M5-UI, M5-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Long questions, all icons and complete controls remain usable in a full match.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
First map and roster art are final, 180 questions are reviewed, 40 paired playtest matches are recorded, and target hardware is measured.

Planning ID: M6-UI


### [M6-QA] Publish question bank and run forty balance matches

## Responsibility
Owner: Member 5 pending name — QA Lead and Learning Content Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M6 — Content completion and balance
Target window: Weeks 12 to 14 from agreed kickoff; no calendar deadline committed.
Estimate: 44 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P1

## Checklist
- [ ] Complete 180 questions: twenty in each of the nine format and difficulty groups.
- [ ] Obtain independent answer review; recruit GAME and UI for scheduled review batches.
- [ ] Run twenty role swapped pairs, forty matches total, across several skill levels.
- [ ] Record role win rate, match length, question income, accuracy, ability picks and failures.
- [ ] Run ten new tester onboarding sessions and summarize observed friction.

## Dependencies
M5-QA, M6-GAME, M6-NET, M6-UI
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
All content has review evidence and playtest results are reproducible by build and pack version.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
First map and roster art are final, 180 questions are reviewed, 40 paired playtest matches are recorded, and target hardware is measured.

Planning ID: M6-QA


### [M7-ART] Sign off final art package and credits

## Responsibility
Owner: Jet Justine — 3D Artist and Animation Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M7 — Release candidate
Target window: Weeks 15 to 16 from agreed kickoff; no calendar deadline committed.
Estimate: 16 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Resolve only release blocking visual issues from the candidate build.
- [ ] Check asset paths and missing textures on a clean machine.
- [ ] Archive source models, textures, rigs and exported files with version labels.
- [ ] Confirm art credit and permission records with QA.

## Dependencies
M6-ART, M6-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Release art is frozen, complete and reproducible from archived sources.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Supported LAN setups, clean machine export, full load performance and two hour repeated match soak pass with no blocking defects.

Planning ID: M7-ART


### [M7-GAME] Close gameplay blockers and freeze rules

## Responsibility
Owner: Member 2 pending name — Gameplay Programmer and Technical Lead
Reviewer: LAN Programmer and Build Owner
Milestone: M7 — Release candidate
Target window: Weeks 15 to 16 from agreed kickoff; no calendar deadline committed.
Estimate: 24 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Pass deterministic transactions, terminal tick, guards and full ability matrix.
- [ ] Fix reproducible crashes, wrong winners and economy duplication in owned code.
- [ ] Freeze release balance data and document known nonblocking limits.
- [ ] Review NET and UI changes that affect simulation authority.

## Dependencies
M6-GAME, M6-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
No known blocking gameplay defect; final rules match the tested release data.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Supported LAN setups, clean machine export, full load performance and two hour repeated match soak pass with no blocking defects.

Planning ID: M7-GAME


### [M7-NET] Build and verify the Windows release candidate

## Responsibility
Owner: Member 3 pending name — LAN Programmer and Build Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M7 — Release candidate
Target window: Weeks 15 to 16 from agreed kickoff; no calendar deadline committed.
Estimate: 26 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Produce the final x86_64 archive with all project and question data.
- [ ] Verify fresh profile, no editor, offline LAN, paths with spaces and intended Unicode paths.
- [ ] Run twenty rematch lifecycle tests and two hour soak with QA.
- [ ] Archive release version, source revision, pack hash, build steps and known issues.

## Dependencies
M6-NET, M6-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
The exact distributable passes clean machine and supported network acceptance.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Supported LAN setups, clean machine export, full load performance and two hour repeated match soak pass with no blocking defects.

Planning ID: M7-NET


### [M7-UI] Close interface blockers and finalize help

## Responsibility
Owner: Member 4 pending name — UI and Arcane Programmer
Reviewer: QA Lead and Learning Content Owner
Milestone: M7 — Release candidate
Target window: Weeks 15 to 16 from agreed kickoff; no calendar deadline committed.
Estimate: 22 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Test corrupt settings recovery, controls, focus, results and every return path.
- [ ] Fix clipped essential text or inaccessible purchases on supported configurations.
- [ ] Add final LAN help, controls, developer pack instructions and credits.
- [ ] Review the exported build with QA using no debug shortcuts.

## Dependencies
M6-UI, M6-QA
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
A new player can complete the full journey with readable UI and accurate help.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Supported LAN setups, clean machine export, full load performance and two hour repeated match soak pass with no blocking defects.

Planning ID: M7-UI


### [M7-QA] Run final release gate and archive evidence

## Responsibility
Owner: Member 5 pending name — QA Lead and Learning Content Owner
Reviewer: Gameplay Programmer and Technical Lead
Milestone: M7 — Release candidate
Target window: Weeks 15 to 16 from agreed kickoff; no calendar deadline committed.
Estimate: 28 focused hours for this card, excluding shared meetings and contingency. Reestimate after the graybox.
Priority: P0

## Checklist
- [ ] Execute the complete release checklist on the exact archive.
- [ ] Record the two hour soak, full load frame times, network cases and role swapped rematches.
- [ ] Verify there are no open crash, softlock, wrong winner, duplicate charge or unusable recovery defects.
- [ ] Publish controls, LAN setup, question author guide, credits and known issues with owners.
- [ ] Prepare go or no go decision and list any accepted minor defects.

## Dependencies
M7-GAME, M7-NET, M7-UI, M7-ART
Dependency IDs identify delivery and integration inputs. Work may start against agreed stubs before dependencies finish; this card cannot be accepted until the required inputs and integration checks pass.

## Done when
Release owner and all five role owners can trace every acceptance item to evidence.

## Evidence required
Link the PR or asset/content delivery, record the build and pack version, and attach the relevant test record or visual preview. Reviewer confirms the checklist before Done. An asset file or passing local test alone is insufficient when the card requires integrated LAN behavior.

## Shared milestone gate
Supported LAN setups, clean machine export, full load performance and two hour repeated match soak pass with no blocking defects.

Planning ID: M7-QA

