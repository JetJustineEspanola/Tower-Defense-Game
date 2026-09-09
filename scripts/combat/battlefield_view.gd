class_name BattlefieldView
extends Node3D

signal node_selected(node_id: int)
var map: BattleMapData = BattleMapData.new()
var camera: Camera3D
var markers: Array[MeshInstance3D] = []
var tower_views: Dictionary = {}
var troop_views: Dictionary = {}
var selected: int = -1
var zoom: float = 1.0
var base_span: float = 61.0
var sun: DirectionalLight3D
var last_shots: Dictionary = {}
var beams: Array[Dictionary] = []

func _ready() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("080f21")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("b4c8ff")
	environment.environment.ambient_light_energy = 0.7
	add_child(environment)
	var light: DirectionalLight3D = DirectionalLight3D.new()
	sun = light
	light.rotation_degrees = Vector3(-55,-30,0)
	light.light_energy = 1.4
	add_child(light)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.position = Vector3(70,70,70)
	add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.current = true
	_camera_size()
	_box(Vector3(68,0.6,48),Vector3(0,-0.6,0),Color("111e34"))
	for i: int in range(1,map.route.size()):
		var a: Vector3 = map.route[i-1]
		var b: Vector3 = map.route[i]
		var dimensions: Vector3 = Vector3(absf(a.x-b.x)+3,0.15,absf(a.z-b.z)+3)
		_box(dimensions,(a+b)/2.0,Color("25516b"))
		for step: int in range(1,int(a.distance_to(b)/5)):
			_box(Vector3(0.6,0.18,0.6),a.lerp(b,float(step)*5/a.distance_to(b))+Vector3.UP*0.12,Color("70cbd9"))
	for i: int in range(map.nodes.size()):
		var cylinder: CylinderMesh = CylinderMesh.new()
		cylinder.top_radius = 1.9
		cylinder.bottom_radius = 2.2
		cylinder.height = 0.35
		var marker: MeshInstance3D = MeshInstance3D.new()
		marker.mesh = cylinder
		marker.position = map.nodes[i]
		marker.material_override = _material(Color("465c91"))
		add_child(marker)
		markers.append(marker)
		var label: Label3D = Label3D.new()
		label.text = "%02d" % (i+1)
		label.position = map.nodes[i]+Vector3(0,0.7,0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 48
		label.pixel_size = 0.025
		add_child(label)
	_instance("res://scenes/maps/code_core.tscn",map.route[-1])
	_instance("res://scenes/maps/attacker_portal.tscn",map.route[0])
	MatchState.updated.connect(refresh)
	SettingsManager.changed.connect(_brightness)
	light.light_energy = 1.4*SettingsManager.values.brightness
	refresh()

func _brightness() -> void:
	sun.light_energy = 1.4*SettingsManager.values.brightness

func _material(color: Color) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	return material

func _box(dimensions: Vector3, at: Vector3, color: Color) -> void:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = dimensions
	node.mesh = mesh
	node.position = at
	node.material_override = _material(color)
	add_child(node)

func _instance(path: String, at: Vector3) -> Node3D:
	var scene: PackedScene = load(path)
	var node: Node3D = scene.instantiate()
	node.position = at
	add_child(node)
	return node

func _camera_size() -> void:
	# Orthographic KEEP_HEIGHT: compensate for narrow play area beside the sidebar.
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var aspect: float = viewport_size.x/maxf(1.0,viewport_size.y)
	camera.size = maxf(base_span,94.0/aspect)*zoom

func change_zoom(amount: float) -> void:
	zoom = clampf(zoom+amount,0.85,1.15)
	_camera_size()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_zoom(-0.05)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_zoom(0.05)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			var origin: Vector3 = camera.project_ray_origin(event.position)
			var direction: Vector3 = camera.project_ray_normal(event.position)
			var hit: Variant = Plane(Vector3.UP,0.0).intersects_ray(origin,direction)
			if hit is Vector3:
				for i: int in range(map.nodes.size()):
					if map.nodes[i].distance_to(hit) <= 2.5:
						select_node(i)
						break

func select_node(id: int) -> void:
	selected = id
	for i: int in range(markers.size()):
		markers[i].material_override = _material(Color("73eaff") if i == id else Color("465c91"))
	node_selected.emit(id)

func refresh() -> void:
	var state: Dictionary = MatchState.view
	if state.is_empty():
		return
	for id: int in state.towers:
		if not tower_views.has(id):
			tower_views[id] = _instance("res://scenes/towers/pulse_spire.tscn",map.nodes[id])
		var tower: Dictionary = state.towers[id]
		if int(tower.shot) > int(last_shots.get(id,0)):
			last_shots[id] = tower.shot
			_beam(map.nodes[id]+Vector3.UP*3,map.point(float(tower.get("target_progress",0)))+Vector3.UP)
	for id: int in state.troops:
		if not troop_views.has(id):
			troop_views[id] = _instance("res://scenes/troops/core_runner.tscn",map.point(state.troops[id].progress))
			var health: Label3D = Label3D.new()
			health.name = "Health"
			health.position.y = 3
			health.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			health.font_size = 32
			health.pixel_size = 0.025
			troop_views[id].add_child(health)
		(troop_views[id].get_node("Health") as Label3D).text = str(maxi(0,ceili(float(state.troops[id].hp))))
	for id: int in troop_views.keys():
		if not state.troops.has(id):
			troop_views[id].queue_free()
			troop_views.erase(id)

func _beam(from: Vector3, to: Vector3) -> void:
	var mesh: ImmediateMesh = ImmediateMesh.new()
	var material: StandardMaterial3D = _material(Color("ab83ff"))
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.surface_begin(Mesh.PRIMITIVE_LINES,material)
	mesh.surface_add_vertex(from)
	mesh.surface_add_vertex(to)
	mesh.surface_end()
	var view: MeshInstance3D = MeshInstance3D.new()
	view.mesh = mesh
	add_child(view)
	beams.append({"node":view,"left":0.16})

func _process(delta: float) -> void:
	for beam: Dictionary in beams.duplicate():
		beam.left -= delta
		if float(beam.left) <= 0:
			beam.node.queue_free()
			beams.erase(beam)
	if camera == null:
		return
	_camera_size()
	for id: int in troop_views:
		if MatchState.view.get("troops",{}).has(id):
			var unit: Dictionary = MatchState.view.troops[id]
			var node: Node3D = troop_views[id]
			var point: Vector3 = map.point(unit.progress)+Vector3(0,0,float(unit.offset-1)*0.75)
			node.position = node.position.lerp(point,minf(1.0,delta*15.0))
			var next: Vector3 = map.point(float(unit.progress)+0.2)
			var forward: Vector3 = next-map.point(unit.progress)
			if forward.length() > 0.01:
				node.rotation.y = atan2(-forward.x,-forward.z)
