extends Node3D

@export_enum("tower", "objective", "guardian", "siege", "economy", "base", "portal") var kind: String = "tower"
@export var team_color: Color = Color("6871ef")

func _ready() -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = team_color
	material.metallic = 0.45
	material.roughness = 0.45
	var dark: StandardMaterial3D = StandardMaterial3D.new()
	dark.albedo_color = Color("17213d")
	var glow: StandardMaterial3D = StandardMaterial3D.new()
	glow.albedo_color = team_color.lightened(0.3)
	glow.emission_enabled = true
	glow.emission = team_color
	glow.emission_energy_multiplier = 1.5
	if kind == "tower" or kind == "guardian":
		_box(Vector3(2.8,0.6,2.8),Vector3(0,0.3,0),dark)
		_box(Vector3(1.6,2.2,1.6),Vector3(0,1.6,0),material)
		_sphere(1.2,Vector3(0,3.2,0),glow)
		_box(Vector3(0.45,0.5,2.4),Vector3(0,2.9,-1),material)
	elif kind in ["objective","siege","economy"]:
		_sphere(1.15,Vector3(0,1,0),material)
		_sphere(0.8,Vector3(0,1.1,-0.9),glow)
		for side: int in [-1,1]:
			for z: float in [-0.65,0.65]:
				_box(Vector3(1.2,0.3,0.25),Vector3(side*1.0,0.35,z),dark)
	elif kind == "base":
		_box(Vector3(5,0.7,5),Vector3(0,0.35,0),dark)
		_box(Vector3(3,3,3),Vector3(0,2,0),material)
		_sphere(1.8,Vector3(0,4.2,0),glow)
	else:
		var ring: TorusMesh = TorusMesh.new()
		ring.inner_radius = 1.8
		ring.outer_radius = 2.5
		var mesh: MeshInstance3D = MeshInstance3D.new()
		mesh.mesh = ring
		mesh.material_override = glow
		mesh.rotation_degrees.x = 90
		mesh.position.y = 2.5
		add_child(mesh)
	for socket: String in ["AttackSocket","HealthBarSocket","VFXSocket"]:
		var marker: Marker3D = Marker3D.new()
		marker.name = socket
		marker.position = Vector3(0,3,-1) if socket == "AttackSocket" else Vector3(0,4,0)
		add_child(marker)

func _box(dimensions: Vector3, at: Vector3, material: Material) -> void:
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = dimensions
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.position = at
	node.material_override = material
	add_child(node)

func _sphere(radius: float, at: Vector3, material: Material) -> void:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius*2
	mesh.radial_segments = 12
	mesh.rings = 6
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.position = at
	node.material_override = material
	add_child(node)
