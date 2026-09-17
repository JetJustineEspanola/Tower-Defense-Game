extends Node3D

var targets = [
	Vector3(7.9, 0.207, 1),      # Point 1
	Vector3(7.9, 0.207, 4.070),   # Point 2
	Vector3(1, 0.207, 4.070),     # Point 3
	Vector3(1, 0.207, 7),         # Point 4
	Vector3(7.9, 0.207, 7),       # Point 5
	Vector3(7.9, 0.207, 10),      # Point 6
	Vector3(1.9, 0.207, 10)       # Point 7
]

var current_target = 0
var speed = 0.4


func _process(delta):
	if current_target >= targets.size():
		return

	var target = targets[current_target]

	var x_difference = target.x - global_position.x
	var z_difference = target.z - global_position.z

	# Move straight along X
	if abs(x_difference) > 0.05:
		global_position.x += sign(x_difference) * speed * delta

	# Move straight along Z
	elif abs(z_difference) > 0.05:
		global_position.z += sign(z_difference) * speed * delta

	# Reached the point
	else:
		global_position.x = target.x
		global_position.z = target.z

		# Rotate for the next direction
		if current_target == 0:
			# Point 1 → Point 2: Face +Z
			rotation.y = deg_to_rad(0)

		elif current_target == 1:
			# Point 2 → Point 3: Face -X
			rotation.y = deg_to_rad(-90)

		elif current_target == 2:
			# Point 3 → Point 4: Face +Z
			rotation.y = deg_to_rad(0)

		elif current_target == 3:
			# Point 4 → Point 5: Face +X
			rotation.y = deg_to_rad(90)

		elif current_target == 4:
			# Point 5 → Point 6: Face +Z
			rotation.y = deg_to_rad(0)

		elif current_target == 5:
			# Point 6 → Point 7: Face -X
			rotation.y = deg_to_rad(-90)

		current_target += 1
