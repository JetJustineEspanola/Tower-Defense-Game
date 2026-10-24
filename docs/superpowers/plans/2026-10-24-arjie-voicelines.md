# Arjie Voicelines Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

## Goal

Play the 12 approved Arjie clips for the defense tower and its Small Arjie guards through the existing shared voice player.

## Files

- `voice_lines/Arjie/*.mp3`: supplied audio assets.
- `voice_lines/Arjie/arjie_voice_bank.tres`: event-to-clip mapping.
- `scripts/combat/jet_voice_bank.gd`, `scripts/combat/jet_voice.gd`, `scenes/combat/jet_voice.tscn`: shared event definitions, cooldowns, Arjie bank registration, and role-aware event delivery.
- `scripts/network/online_match.gd`: relay authoritative Arjie events to a defender guest.
- `scripts/towers/starter_tower.gd`: Arjie tower placement, selection, upgrade, summon, low health, and defeat calls.
- `scripts/towers/defender.gd`, `scripts/towers/guard_orders.gd`: Small Arjie attack, hurt, defeat, and reposition calls.
- `tests/audio/arjie_voice_test.gd`: headless mapping and integration checks.

## Steps

- [x] Add a test for all 12 clip assignments, bank registration, and playable Arjie events; run it and confirm failure.
- [x] Add Arjie's voice bank and shared event definitions; run the test.
- [x] Connect tower events and Small Arjie events to the shared player; run focused test and Godot import.
- [x] Relay authoritative Arjie events to a defender guest and suppress replica playback.
- [x] Review changed files and run existing headless tests plus a project startup check.

## Manual check

Start a local match as defender. Place, select, and upgrade Arjie; summon guards, move a guard, and let a guard attack, take damage, and die. Damage the tower below 25% HP and destroy it. Verify the expected clips play with shared cooldowns. Confirm Jet and online scenes still start.
