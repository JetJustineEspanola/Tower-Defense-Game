class_name MatchClock
extends Node

signal changed(seconds: int)
signal expired
@export_range(1, 3600) var duration_seconds: int = 720
var remaining: float = 0.0
var running: bool = false
var displayed_seconds: int = -1

func _ready() -> void:
	start()

func start() -> void:
	remaining = float(duration_seconds)
	running = true
	_update_display()

func _process(delta: float) -> void:
	if not running:
		return
	remaining = maxf(0.0, remaining - delta)
	_update_display()
	if remaining == 0.0:
		running = false
		expired.emit()

func _update_display() -> void:
	var seconds := ceili(remaining)
	if seconds != displayed_seconds:
		displayed_seconds = seconds
		changed.emit(seconds)
