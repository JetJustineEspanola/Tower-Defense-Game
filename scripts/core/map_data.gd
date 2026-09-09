class_name BattleMapData
extends RefCounted

var route: PackedVector3Array = []
var nodes: PackedVector3Array = []
var length: float = 0.0

func _init() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/data/map.json"))
	for p: Array in data.route:
		route.append(Vector3(p[0], p[1], p[2]))
	for p: Array in data.nodes:
		nodes.append(Vector3(p[0], p[1], p[2]))
	for i: int in range(1, route.size()):
		length += route[i - 1].distance_to(route[i])

func point(distance: float) -> Vector3:
	for i: int in range(1, route.size()):
		var segment: float = route[i - 1].distance_to(route[i])
		if distance <= segment:
			return route[i - 1].lerp(route[i], clampf(distance / segment, 0.0, 1.0))
		distance -= segment
	return route[-1]
