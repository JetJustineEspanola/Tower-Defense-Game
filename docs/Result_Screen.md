# Shared match result screen

Edit `scenes/ui/match_result.tscn` for both roles. Titles, captions, stats, tips and buttons are real Godot Control nodes. `scripts/ui/match_result.gd` fills the match values and selects cyan victory or red defeat styling. Preview the layout by enabling the root CanvasLayer's Visible property in the editor; leave it hidden when saving for gameplay.

Background art is in `assets/ui/results/victory.png` and `defeat.png`. These contain illustration only; text and buttons remain editable. Built-in image generation produced the artwork using this brief: landscape anime chibi sci-fi fantasy hero with robot cat in dark ruins, cyan crown and celebration for victory, broken crimson shield and disappointed hero for defeat, no baked-in text or UI, dark lower area for scene controls.

Attacker wins on destroying the enemy base and loses on timeout. Defender wins on timeout with surviving base and loses at zero health. Both display elapsed match time, gold earned during the match (excluding starting funds), and the appropriate base's remaining health. Rewards, XP and next-stage navigation are not implemented gameplay systems and are not shown.

Home opens the existing menu. Play Again/Retry reloads the current role's scene. Showing results pauses gameplay; returning to play clears that pause. The result screen handles Escape so it cannot reopen the pause menu behind it.

Validation: all four outcomes, gold accounting and retry state were checked in Godot 4.6, and both visual themes were captured for review.
