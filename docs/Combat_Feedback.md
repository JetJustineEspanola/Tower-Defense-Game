# Combat feedback

Towers, troops and guards instance scenes/combat/health_feedback.tscn. Adjust the Back and Fill sprites for bar size, and the Value Label3D for text size. Each actor scene positions HealthFeedback above its model. Bars turn amber below half health and red at one quarter health.

Damage is reported after armor and capped at remaining health. Each hit creates a floating number, small CPU particle spark burst and a brief material overlay flash. Original overlays are restored; movement and attacks are not interrupted.

Edit scenes/combat/damage_popup.tscn to change number styling, sparks and sound volume. Three original synthesized sounds are stored in assets/audio/combat: hit.tres, fall.tres and base.tres. Up to four ordinary impacts may sound in each 60 millisecond window. Base hits have a separate heavier sound and BASE damage label. Hit volume is -6 dB; the hit clip has a sharp attack and a low thock.

The fill uses a cropped texture and pixel offset so its left edge stays fixed as health decreases, including when the actor turns. Zero health hides the fill completely.

Health updates include upgrades that change maximum health. Feedback follows pause behavior; a lethal base cue can finish over the result screen. Existing attack, summon, income effects and combat music continue to work.

Verified in Godot 4.6 with damage to a tower, Ronel, a guard and the base; also checked lethal troop damage and popup cleanup. Sound playback is wired and uses generated audio; final loudness should be reviewed by ear during team playtesting.
