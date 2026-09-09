---
name: blender-game-assets
description: Create, revise, retheme, and validate game-ready Blender characters, towers, props, and modular environments, including modeling, UVs, materials, rigging, animations, and engine export. Use for Blender asset production or art-direction changes; not standalone 2D art or gameplay/network code.
---

# Blender Game Assets

Produce editable source models and verified engine-ready assets. Keep the workflow theme-neutral: animals, robots, fantasy, urban, realistic, or other directions come from the current brief, not this skill. Apply only the production stages an asset needs.

## Establish scope and tool access

- Read applicable project instructions, the current art brief, asset specifications, relevant source files, and available references before editing.
- Determine Blender and target-engine versions, available Blender executable or configured integration, export requirements, and target hardware. Use version-matched official documentation for APIs and export settings.
- Use an existing authorized Blender integration or Blender Python execution. Do not install extensions, change preferences, enable untrusted embedded scripts, or upload private assets to third-party generators without authorization.
- If Blender execution is unavailable, say so. Offer a runnable script or modeling plan within the request; label it unexecuted rather than claiming a model, render, or verified export exists.
- Inspect an existing scene before changing it. Preserve unrelated collections, source models, rigs, materials, animation data, and user edits. Save variants without overwriting approved originals unless replacement is explicitly requested.

## Resolve the active art direction

Use explicit current user instructions over older project art direction. Treat older assets as references, not permission to override a newly requested theme. Ask a focused question only when conflicting instructions or missing choices would materially change the result.

Find the existing art-direction record first. If none exists and asset creation is requested, propose or record a compact brief using these fields; do not create competing sources of truth:

- Theme and art-direction version.
- Approved references and references to avoid.
- Shape language, proportions, silhouette, and detail density.
- Palette roles: primary, secondary, accent, team indication.
- Surface treatment: stylized, flat, hand-painted, or PBR.
- Camera angle, typical screen size, lighting, and background contrast.
- Target engine/version, hardware, and expected simultaneous instance count.
- Asset role, dimensions, placement footprint, pivot, forward direction.
- Geometry, texture, material, bone, and animation budgets where known.
- Required sockets, animation names, root-motion policy, and export format.
- Requested delivery stage: blockout, production asset, or integrated asset.

Use provisional defaults for reversible details and disclose them. Do not treat a chibi style, low-poly look, fixed palette, or Primal Towers setting as a permanent requirement.

## Retheme without breaking integration

1. Identify the selected assets and requested visual changes. Do not assume a request to retheme one asset covers the entire game.
2. Separate presentation choices from integration contracts. Preserve asset IDs, placement footprints, pivots, sockets, animation names, and collision behavior unless changes are approved.
3. State changes that cannot preserve compatibility. A quadruped-to-biped change may require a new rig and animations; do not promise safe skeleton reuse.
4. Reuse compatible modules, materials, and rigs deliberately. Keep palette roles and surface parameters configurable; do not implement every theme as recoloring alone.
5. For a broad asset family or major theme shift, produce one representative blockout or pilot before batch conversion. Get visual direction confirmed before expensive dependent work unless the user has delegated that choice.
6. Keep the previous approved variant recoverable and record which art-direction version each new asset follows.
7. Verify the rethemed asset under the actual gameplay camera. Keep roles, factions, and upgrade tiers distinguishable through silhouette or markings as well as color.

## Model from blockout to production mesh

- Establish dimensions, pivot, orientation, silhouette, and modular connections before surface detail. Judge readability at intended gameplay scale, not only close-up renders.
- Use mesh modeling, sculpting with retopology, or procedural generation according to the shape and editing needs. Primitive blockouts are not automatically finished production models.
- Preserve non-destructive source modifiers when useful. Create controlled export meshes for operations that would damage source editability.
- Use edge flow appropriate for deformation; use efficient topology for rigid props. Do not require all-quads for runtime meshes or blindly decimate articulated characters.
- Check accidental duplicate geometry, zero-area faces, incorrect normals, unwanted intersections, and unintended open boundaries. Permit intentional open surfaces such as foliage cards.
- Evaluate final triangulation and shading on export. Count exported triangles and vertices, including UV/normal splits, rather than relying only on source polygon counts.
- For modular environments, verify grid increments, pivots, seams, tiling, and attachment alignment.
- For upgrades, preserve recognizable base identity while providing readable visual differences.

## UVs, materials, and textures

- Unwrap with deliberate seams, sufficient island padding for mipmaps, and consistent texel density appropriate to camera distance.
- Use mirrored or overlapping UVs intentionally; keep unique UV space where asymmetric painting or baking requires it. Supply a separate lightmap UV set only when the engine workflow needs it.
- Select palette textures, vertex colors, trim sheets, atlases, or unique PBR textures according to the brief and target engine support.
- Use export-compatible material graphs. Bake procedural appearance when the target format cannot reproduce it; do not assume Blender shader nodes transfer intact.
- Handle base-color and data-map color spaces correctly; verify normal-map orientation and tangent-space shading after import.
- Minimize unnecessary material slots and transparent overdraw. Set alpha, culling, roughness, metallic, and emission deliberately.
- Preserve editable texture sources. Pack or use portable relative paths for dependencies, and verify missing-texture behavior by reopening the deliverable.
- Do not promise identical Blender and engine rendering; compare under controlled lighting and then the gameplay lighting.

## Rigging and animation, when required

- Choose the rig from anatomy and motion requirements. Keep rigid parts parented where skinning is unnecessary.
- Establish scale, bind pose, bone orientation, and root-motion policy before animation. Do not blindly apply transforms to an existing bound rig.
- Separate animation controls from the export skeleton where supported. Bake constraints and drivers into supported animation data when necessary.
- Check weights, unweighted vertices, influence limits, deformation at extreme poses, and unwanted mesh intersections.
- Preserve required socket and bone names; export needed attachment bones even when they do not deform the mesh.
- Create only requested clips. Define names, timing, frame rate, loop behavior, and events expected by gameplay.
- Inspect loop seams, foot sliding, contact poses, attack direction, idle motion, and bounds. Do not introduce root motion when movement is engine-controlled.
- Confirm the installed Blender version's action/slot/NLA export behavior. Verify clips are exported separately with the intended names and durations.

## Safe procedural work

- Parameterize dimensions, shape proportions, palette roles, detail levels, and variation seeds when creating reusable generators.
- Prefer deterministic seeds for reproducibility. Scope generated objects to a named asset collection with stable identifiers.
- Make reruns update or replace only owned generated content. Never clear an entire user scene as a routine setup step.
- Prefer Blender's data API where practical; set explicit context when operators are necessary.
- Validate arguments and output paths. Avoid embedded secrets, arbitrary downloads, or unrestricted execution of external scripts.
- Test new generators with Blender and inspect their output. Syntax checks alone do not prove geometry, rigging, or export correctness.

## Export and verify

- Preserve an editable .blend source and required texture dependencies. For Godot, prefer GLB/glTF unless the project deliberately uses another supported pipeline.
- Export only intended collections/objects and required skeleton/animation data. Exclude reference images, studio lights, and presentation cameras unless requested.
- Let the exporter handle coordinate conversion and verify the result; avoid applying an additional rotation or scale conversion blindly.
- Check evaluated meshes, material compatibility, animation export, shape keys, and required attachments using version-appropriate settings.
- Keep collision geometry simple and separate from render detail. Preserve approved gameplay collision during visual-only changes.
- Reimport the exported asset into a fresh inspection scene. When the engine is available, verify in that engine too: scale, facing, pivot, textures, shading, clips, sockets, and collision.
- Inspect front, side, back, and gameplay-camera views, plus animated poses where relevant. Do not claim visual QA from a headless export alone.
- Test performance at representative instance counts before declaring a budget met. Add LODs or simplify measured bottlenecks without sacrificing needed silhouettes or deformations.
- Deliver source, export, necessary textures, and useful preview images as requested. Report versions, art-direction version, triangle/material/texture statistics, clip names, checks actually run, and remaining limitations.
- If Blender or engine verification is unavailable, explicitly separate generated files from unverified outputs. Do not claim game-ready integration without the relevant checks.

## Official references

Consult only relevant documentation, selecting the installed software version:

- Blender manual: https://docs.blender.org/manual/en/latest/
- Blender Python API: https://docs.blender.org/api/current/
- Godot 3D asset pipeline: https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_3d_scenes/index.html
