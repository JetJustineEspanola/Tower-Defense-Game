# Contributing to CodeBorn

Use Godot 4.6 stable and start from the reviewed development branch. Keep a playable main branch; open a feature branch per bounded change, such as `feat/net-discovery`, `feat/game-mana-mint`, `feat/ui-loadout`, `content/questions-loops`, or `art/pulse-spire`. Keep commits focused, include Godot `.uid` sidecars, and exclude `.godot`, exported builds, logs, local settings, and temporary captures.

The five work areas and service boundaries are in `docs/architecture.md`. Discuss changes to command shapes, stable IDs, timing rules, asset pivots, or content versioning in the PR before merging. Additive implementation can proceed against existing definitions and placeholder scenes. Do not edit another contributor's generated import cache or bake combat code into final art.

Every PR states the concrete problem/result, affected interfaces, validation actually run, and remaining limits. Include screenshots for UI/art, regression cases for gameplay authority changes, and two-instance evidence for networking changes. Have a reviewer from the adjacent work area inspect integration. Code changes do not constitute educational content approval or art signoff.

Run `tools/verify.ps1 -Godot <path>` for import, rules, UI smoke and two-process networking. Tests require no external framework. A passing editor import alone does not prove gameplay. Run two physical Windows PCs before accepting M1. Use the defect issue template to record reproducible failures.

Existing issue assignees identify responsibility, not exclusive edit rights. Leave partially fulfilled issues open with a concise evidence-linked progress note. M0 requires all five owners' agreement and a Windows baseline on both PCs. M1 requires actual two-PC matches. Do not close these gates based solely on a localhost test or a generated asset.

Use `dev/codeborn-foundation` as the initial integration PR. Do not merge or rewrite main automatically. Subsequent contributors can branch from it while review is pending, then rebase after it merges.
