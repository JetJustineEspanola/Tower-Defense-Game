class_name TowerPlacementPad
extends Area3D

signal selected(pad: TowerPlacementPad)
var occupied: bool = false
var tower: Node3D

func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(self)
	elif event is InputEventScreenTouch and event.pressed:
		selected.emit(self)
