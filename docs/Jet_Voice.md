# Jet recorded voice integration

Original recordings: voice_lines/Jet/*.m4a (unchanged).
Game-ready copies: voice_lines/Jet/ready/*.wav, mono PCM16 at 48 kHz.
Editable event bank: voice_lines/Jet/jet_voice_bank.tres.
Scene/player: scenes/combat/jet_voice.tscn, using the Voice bus and existing volume slider.

All 25 takes are assigned by their provided filenames: placement, selection, upgrade, attack efforts, upgraded attacks, light/heavy hurt, still standing/low health, and defeat. Only friendly Jet attack towers speak; enemy AI towers do not compete with the local player's voices. Alternate takes avoid immediate repetition. Attack/hurt attempts are occasional and share cooldowns across towers. Low-health dialogue is attempted once per tower below 25% HP. Defeat plays from the shared player so removing the tower does not cut it off. Announcer lines interrupt character audio; dropped lines are not queued. Pausing uses the pausable audio node; match end stops character voice.

Polish: 75 Hz high-pass; broad -1.5 dB at 280 Hz and +1.5 dB at 3 kHz; gentle 1.6:1 compression with 15 ms attack and 140 ms release; conservative edge silence trim preserving 150 ms before and 200 ms after detected sound; gain capped at 3x with peaks no higher than -3 dBFS. No pitch shifting, time stretching, reverb or artificial emotional transformation. Conversion manifest records each duration, trim, gain and peak. Quiet takes are not forced to identical loudness. Processing cannot repair the acting or guarantee recovery of distortion in the original recording.

Runtime validation: all 25 WAVs load with valid duration, every bank requests playback, repeat cooldowns reject spam, actual placement/selection/upgrade/low-health/death hooks work, defeat survives tower deletion, and announcer playback interrupts Jet. Subjective clarity and performance/emotional quality still require listening in the actual game mix. No verbatim character subtitles were added because source speech was not transcribed or verified.
