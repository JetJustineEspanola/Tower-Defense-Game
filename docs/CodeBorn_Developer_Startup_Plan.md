# CodeBorn Beginner Developer Startup Plan

Project board: https://github.com/users/JetJustineEspanola/projects/1/views/2

Repository: https://github.com/JetJustineEspanola/Tower-Defense-Game

Miro reference: https://miro.com/app/board/uXjVHq86R4M=/

## Beginner first decision

The team should not begin with LAN multiplayer, the complete Arcane Question system, five abilities, or advanced enemy navigation. Those features require several smaller Godot skills first.

The first goal is a small offline prototype that teaches the team how Godot scenes, nodes, scripts, signals, resources, and GitHub branches work. It contains only a starting screen, a graybox map, gold and mana labels, one stationary tower, one bug moving along one path, and a simple base target.

Each developer builds a tiny test scene before connecting work to the main scene. A task is complete when another team member can open and run it without special instructions.

## Who starts first

| Order | Owner | First beginner task | Start time |
|---|---|---|---|
| 0 | Whole team | Install Godot 4.6, clone the repository, and run the project | Day 1 together |
| 1 | Core and UI | Create the starting screen and empty scene destinations | Day 1 |
| 1 | Jet 3D Art | Create the graybox map and correctly scaled placeholders | Day 1 in parallel |
| 2 | Economy and Arcane | Create local gold and mana counters in a test scene | Day 2 |
| 2 | Tower Combat | Make one tower detect and damage one stationary dummy | Day 2 |
| 2 | Bugs and Pathfinding | Make one bug move along one visible path | Day 2 |
| 3 | Whole team | Combine the five basic pieces into one offline scene | End of Week 1 |

The Core and UI developer and Jet start first because everyone needs a runnable project, a screen to launch from, and a graybox space. The other three developers can start on Day 2 using small isolated scenes.

## What the team should learn first

Every programmer should complete a short practice scene covering:

- Opening and running a Godot project.
- Creating and saving a scene.
- Adding and renaming nodes.
- Attaching a typed GDScript.
- Using exported variables in the Inspector.
- Connecting a signal through code or the editor.
- Instantiating one reusable scene.
- Reading an error in the Debugger.
- Creating a branch and committing a small change.

Do not copy a large system without understanding which scene owns it and how it is started.

## Simple project folders

Use a small structure during the beginner phase:

- `scenes/ui` for the starting screen and temporary destination screens.
- `scenes/gameplay` for the offline integration scene.
- `scenes/towers` for the tower test scene.
- `scenes/troops` for the bug path test scene.
- `scenes/maps` for the graybox map and Path3D.
- `scripts` for shared beginner scripts.
- `assets/placeholders` for primitive models and temporary art.
- `docs` for team instructions.

Add more folders only when a real feature needs them.

## Beginner task for Core and UI

**Goal:** Create only the starting screen shown in the Miro reference.

**Learn first:** Control nodes, containers, anchors, button signals, and scene changing.

**Steps:**

1. Create `starting_screen.tscn` with a full-screen Control root.
2. Add the CodeBorn title.
3. Add Play, Settings, Developer, and Quit buttons in a centered vertical container.
4. Make Play open a temporary scene containing the text `Play Screen Placeholder` and a Back button.
5. Make Settings open a temporary scene containing one volume slider and a Back button.
6. Make Developer open a temporary scene containing the text `Question Editor Placeholder` and a Back button.
7. Make Quit close the running game.
8. Set the starting screen as the main project scene.
9. Test the screen at 1366 by 768 and 1920 by 1080.

**Done when:** Every button works, every placeholder screen can return to the starting screen, and no text or button is clipped at either test resolution.

**Do later:** LAN browser, lobby, role reveal, final HUD, settings persistence, animations, and polished visual effects.

## Beginner task for Jet 3D Art

**Goal:** Provide simple, replaceable objects that let the programmers build gameplay.

**Learn first:** Godot scale, imported GLB orientation, pivots, materials, and the fixed isometric camera view.

**Steps:**

1. Agree that one Godot unit represents one meter.
2. Create a flat graybox ground plane.
3. Add one clearly visible route from attacker spawn to defender base.
4. Mark one attacker spawn point and one defender base point.
5. Add three simple tower deployment markers.
6. Create one tower placeholder using simple shapes.
7. Create one bug placeholder using simple shapes.
8. Export the tower and bug as separate GLB files.
9. Record the forward direction, pivot location, size, and filename for each asset.
10. Check that the route and deployment markers are visible from the isometric camera.

**Done when:** Another team member imports the map, tower, and bug at the correct size without rotating, moving, or renaming them.

**Do later:** Final character models, detailed textures, complete rigs, ability effects, destruction animation, and environment decoration.

## Beginner task for Economy and Arcane

**Goal:** Make a local test scene that changes gold and mana correctly.

**Learn first:** Variables, labels, buttons, Timer nodes, signals, and simple validation.

**Steps:**

1. Create `resource_test.tscn`.
2. Start with 100 gold and 50 mana.
3. Display both values using Label nodes.
4. Add an `Earn 10 Gold` test button.
5. Add a `Spend 25 Gold` test button.
6. Prevent spending when gold is below 25.
7. Add a Timer that restores one mana at a slow test interval.
8. Add one Multiple Choice question with three answer buttons.
9. Award gold once for the correct answer.
10. Disable the answers after the question is completed.

**Done when:** Gold never becomes negative, mana increases through the Timer, and the question reward can be received only once.

**Do later:** Passive economy towers and troops, difficulty rewards, question refresh, question skip, JSON question packs, the developer editor, and network authority.

## Beginner task for Tower Combat

**Goal:** Make one tower detect and damage one stationary dummy.

**Learn first:** Reusable scenes, Area3D, collision layers, Timer nodes, signals, and exported statistics.

**Steps:**

1. Create `basic_tower.tscn` with a Node3D root.
2. Add the placeholder tower model.
3. Add an Area3D with a visible debug range.
4. Create a stationary dummy with 50 health.
5. Detect when the dummy enters the tower range.
6. Use a Timer to deal 10 damage once per second.
7. Display the dummy health using a Label.
8. Stop attacking when the dummy reaches zero health.
9. Print or display `Dummy defeated` once.
10. Expose range, damage, and attack interval in the Inspector.

**Done when:** Moving the dummy into range starts attacks, moving it out stops attacks, and defeat happens exactly once.

**Do later:** Tower purchasing, deployment validation, armor, projectiles, splash attacks, multiple targets, defend towers, economy towers, and tower upgrades.

## Beginner task for Bugs and Pathfinding

**Goal:** Make one bug follow one path from spawn to base.

**Learn first:** Path3D, PathFollow3D, process movement, exported speed, reusable scenes, and arrival signals.

**Steps:**

1. Create `bug_path_test.tscn`.
2. Add a visible Path3D with a short curved route.
3. Create `basic_bug.tscn` using the placeholder bug model.
4. Place the bug under a PathFollow3D node.
5. Move it forward at a constant exported speed.
6. Add a Start button that resets and launches the bug.
7. Add a Stop or Reset button for testing.
8. Detect when the bug reaches the end.
9. Display `Base reached` exactly once.
10. Test with slow and fast movement values.

**Done when:** The bug starts at the correct position, follows the full route without leaving it, and announces arrival only once.

**Do later:** Training queues, groups of bugs, collision avoidance, siege targeting, tower blocking, health, armor, death, and troop upgrades.

## Beginner offline integration task

**Goal:** Combine the separate practice scenes into one small offline demonstration.

**Steps:**

1. Play opens the offline gameplay scene.
2. The graybox map and fixed isometric camera appear.
3. Gold and mana labels appear without their test buttons.
4. One tower is already placed beside the route.
5. One button spawns or starts one bug.
6. The bug follows the route.
7. The tower damages the bug when it enters range.
8. If the bug dies, display `Bug defeated`.
9. If the bug survives, reduce the base health once.
10. A Back button safely returns to the starting screen.

**Done when:** A new team member can clone the repository, open Godot, press Play, navigate into the demonstration, run both possible outcomes, and return to the starting screen.

## Week 1 beginner schedule

| Day | Team result |
|---|---|
| Day 1 | Everyone runs the project. Starting-screen and graybox branches begin. |
| Day 2 | Resource, tower, and bug-path test scenes begin using placeholders. |
| Day 3 | Each developer demonstrates their small scene to one teammate. |
| Day 4 | Fix scene errors and connect the simplest versions in the offline gameplay scene. |
| Day 5 | Demonstrate the complete offline beginner prototype and record what was learned. |

There is no requirement to finish LAN networking during Week 1.

## Week 2 beginner schedule

Week 2 makes the offline prototype safer and easier to extend:

- Replace print statements with small on-screen feedback labels.
- Move repeated statistics into simple Godot Resource files.
- Add a basic base-health label.
- Add a basic spawn delay using one Timer.
- Add a basic deployment-node click test.
- Add one settings volume slider that remains while changing local scenes.
- Add short README instructions for running each test scene.
- Fix warnings and errors before starting multiplayer.

At the end of Week 2, decide whether the team is ready for LAN host and join work.

## Features deliberately postponed

Do not add these to the beginner startup cards:

- UDP lobby discovery.
- Host-authoritative replication.
- Random networked role assignment.
- Rematch synchronization.
- Complete attacker and defender shops.
- Economy towers and economy bugs.
- Siege targeting and blocking troops.
- Five finished abilities per unit.
- Two-slot upgrade selection UI.
- Full Arcane Question editor and content packs.
- Final victory and defeat statistics.
- Advanced pathfinding or dynamic avoidance.

These remain part of the full CodeBorn plan and begin after the offline prototype is stable.

## GitHub board cards

Use these six beginner cards:

1. `[BEGINNER-01] Project setup and starting screen`
2. `[BEGINNER-02] Basic gold mana and one question test`
3. `[BEGINNER-03] Basic tower range and damage test`
4. `[BEGINNER-04] Basic bug path movement test`
5. `[BEGINNER-05] Graybox map and placeholder art`
6. `[BEGINNER-06] Offline beginner prototype integration`

BEGINNER-01 and BEGINNER-05 start first and remain In Progress. BEGINNER-02, BEGINNER-03, and BEGINNER-04 remain Todo until their developers can run the project and their required placeholder scene exists. BEGINNER-06 remains Todo until the five small pieces work separately.

## Beginner working rules

- Keep each first pull request small enough to review in about fifteen minutes.
- Put only one feature in each test scene.
- Use descriptive node and file names.
- Ask another developer to run the scene before marking the card Done.
- Commit working checkpoints instead of one very large final commit.
- Never mark a task Done because the code was written; run the scene and show the result.
- Use placeholders without waiting for final models or polished UI.
- Read the first debugger error before changing several files.
- When stuck for more than one hour, write the exact error and ask a teammate for help.

