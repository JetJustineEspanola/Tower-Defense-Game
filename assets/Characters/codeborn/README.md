# CodeBorn character imports

Source: the user's Desktop/Codeborn Models folder. Original Blender files
are preserved. These GLB exports include the source materials and packed textures.

| Export | Source | Game role |
| --- | --- | --- |
| ren.glb | in-m/outputs/Ren_Sword_Animated.blend | Jet attack tower, including animated sword rig |
| arjie.glb | Arjie - Defender Tower.blend | Defense tower and smaller spawned guard |
| canguit.glb | Canguit- Economy Bug.blend | Economy tower placeholder and economy bug visual |
| ronel.glb | Ronel - Economy Bug.blend | Objective bug, per the user's corrected role |
| matthew.glb | Matthew - Siege Bug.blend | Siege bug visual |

The active tower scenes, defender scene and combat_bug scene use these models
as Model children. Gameplay logic and pivots remain in the wrapper scenes.
Adjust Model scale there rather than changing the imported source.

Exports include idle/action clips: Sword_Idle/Attack, Knight_Idle/Attack,
Market_Idle/Support_Cast, Book_Idle/Attack and Siege_Idle/Attack_Deploy.
The supplied character files already contain the matching actions from the
in-m production workflow. Jet uses the animated sword source from in-m.
Ronel's separate REN comparison mannequin is excluded and its rig is recentered.

CharacterAnimation in each wrapper loops idle, plays one action, then returns
to idle. Damage is applied at 45% of the action duration and revalidates the
target then. Action length is scaled to fit the gameplay attack interval.
Income and guard deployment trigger their support/action clips.
Pause freezes playback and impact timers. Match end stops playback and damage.

Tower Models use an editable Y rotation of -180 degrees while idle. Attack towers
turn toward a living target in range and return to that rotation when it leaves.
Only the visual rotates; the tower root stays centered on the deployment node.

Walking loops: Arjie/Knight_Walk, Canguit/Market_Walk, Ronel/Book_Walk,
Matthew/Siege_Walk. These are one-second, in-place skeletal loops with matching
endpoints, preserving the idle carrying pose and existing attack animations.
CharacterAnimation.set_moving(true/false) blends between walking and idle.
Ronel walks while advancing along the route and stops when blocked. Arjie's guard
walks from its tower to its road position before it can block enemies.
Towers themselves remain stationary. Siege targeting is separate from playback.

Canguit and Matthew have reusable economy_bug_visual.tscn and
siege_bug_visual.tscn wrappers in scenes/towers. These two visual scenes
do not implement economy-bug income or siege targeting. The active practice
bug uses Ronel and follows the base route; it does not attack towers.
