extends RefCounted
## First/Last refer to progress along the route, not spawn order or distance.
static func select(candidates: Array, origin: Vector3, mode: int) -> Node3D:
	var best: Node3D
	for candidate in candidates:
		if not is_instance_valid(candidate) or candidate.is_queued_for_deletion() or not candidate.alive: continue
		if best == null or preferred(candidate, best, origin, mode): best = candidate
	return best

static func preferred(a: Node3D, b: Node3D, origin: Vector3, mode: int) -> bool:
	match mode:
		1:
			if a.progress != b.progress: return a.progress < b.progress
		2:
			if a.health != b.health: return a.health > b.health
		3:
			if a.health != b.health: return a.health < b.health
		4:
			var ad: float = origin.distance_squared_to(a.global_position)
			var bd: float = origin.distance_squared_to(b.global_position)
			if not is_equal_approx(ad, bd): return ad < bd
	if a.progress != b.progress: return a.progress > b.progress
	return a.get_instance_id() < b.get_instance_id()
