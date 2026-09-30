# Resource bar and Arcane Question

Open maps/main_map.tscn and press F6, or press F5 to run the project.
The existing scenes/Arcane_question/arcane_question_test.tscn is instanced at
Gameplay/ResourceHUD/ArcaneQuestionTest. Run that scene alone with F6 to edit
the interface without the map.

## Where to edit

Open arcane_question_test.tscn and select the **2D** workspace. Expand its
root in the Scene tree, then select the individual Label or Button.
In main_map.tscn, expand Gameplay > ResourceHUD > ArcaneQuestionTest:
Editable Children is enabled so its controls can also be selected there.
Edit the original scene for shared changes; map edits are instance overrides.
Containers control child positions, so adjust container separation, margins
and child minimum sizes instead of dragging container-managed children.

- TopBar/Row contains the brand, Gold, Mana, Time and Health cards.
- QuestionPanel/Scroll/Content contains the question, code, four answers,
  Submit, feedback and New Question.
- Resources stores starting gold (100), mana (50) and mana cap (50).
- Resources/ManaTimer restores one mana every five seconds.
- MatchClock exposes Duration Seconds (720 by default).
- The scene root exposes preview health, question cost and reward.
- QuestionToggle is the persistent edge button for collapsing the sidebar.
- TopBar/Row/PauseButton opens PauseOverlay, with Resume and Main Menu.

Every Control node is saved in the scene, not constructed at runtime.
Containers align the controls; anchors keep the bar at the top and the panel
at the right. The sidebar can scroll on shorter windows. The project uses
its existing 1366x768 canvas stretch settings.

The reusable theme is assets/ui/resources/hud_theme.tres. The SVG frame and
icons in that folder are editable vector artwork inspired by the reference,
so numbers remain live Labels rather than baked into an image.

## Current behavior

Select A, B, C or D, then Submit. A (14) gives 25 gold once; incorrect answers
give none. All answers lock after submission. New Question costs 10 mana
and resets the same sample question. Below 10 mana, the button is disabled.
Hide/Show Question keeps balances, selection and completion state.

Time counts down from 12:00 to 00:00. MatchClock emits expired exactly once;
win/results logic can connect to that signal later. Menu or Escape pauses
the scene tree, including the clock and mana regeneration. Resume or Escape
continues play. Main Menu clears pause before opening the starting screen.
Base health (100/100) is still a preview; gameplay can call
set_base_health(health, maximum) later.

PlayerResources owns balances and emits changed(gold, mana). Future purchases
should call spend_gold/spend_mana and check their boolean result. The question
UI calls add_gold for a correct submission; it does not keep another balance.

## Verified

Godot 4.6 rendered review and input checks cover selection/Submit, duplicate
submission, wrong answers, insufficient funds, capped timer regeneration,
hide/show persistence and the time/health display methods.

Countdown progression, pause/resume, zero clamping and the collapsed toggle
were also checked in a rendered Godot 4.6 run.

Next: connect timer expiry and base health to match outcomes.
Question packs remain a separate task.
