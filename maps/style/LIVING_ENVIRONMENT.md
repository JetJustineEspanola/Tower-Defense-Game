# Living environment

Open `main_map.tscn` and run the scene to see wind and water motion.

Select `LivingEnvironment` to adjust **Wind Strength** (default 1.0; 0 disables wind). Tree tops sway approximately 4.5 cm at default strength; small plants sway approximately 1.8 cm. Roots remain anchored. Gusts roll through about every eight seconds, with world-position variation.

The controller uses local material copies. Existing toon materials retain their colors and lighting; imported vegetation receives matte toon shading. The same wind function drives the mesh and its outline, including existing separate outline hulls.

Water uses broad blue/cyan bands, downward waterfall highlights, and softly pulsing foam. Geometry and flow layout are retained.

The lower ground-level stream around X=11 uses a reversed horizontal flow direction so its highlights travel away from its waterfall. The upper stream and vertical waterfalls retain their original directions.

`main_map_before_wind.tscn` is the scene copy from before this update. Its scene UID is omitted to avoid a duplicate UID. It uses the original, unchanged assets and outline controller. The exact original scene bytes are also retained in the workspace backup.

No per-frame mesh rebuilding or physics simulation is used. Animation runs in the GPU shaders. New vegetation added after runtime setup requires re-running the scene to receive wind.
