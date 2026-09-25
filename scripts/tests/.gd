extends CharacterBody3D

signal defeated

@export var speed: float = 1.0
@export var max_health: float = 50.0

var current_health: float = 50.0
var is_defeated: bool = false

func _ready() -> void:
	reset_dummy()

func _process(delta: float) -> void:
	var parent = get_parent()
	if parent is PathFollow3D:
		parent.progress += speed * delta

func take_damage(amount: float) -> void:
	if is_defeated:
		return
		
	current_health -= amount
	update_health_display()
	
	if current_health <= 0:
		defeat_dummy()

func update_health_display() -> void:
	if has_node("HealthLabel"):
		$HealthLabel.text = str(max(0, int(current_health)))

func defeat_dummy() -> void:
	if not is_defeated:
		is_defeated = true
		print("Dummy defeated")
		defeated.emit()
		var parent = get_parent()
		if parent is PathFollow3D:
			parent.queue_free()
		else:
			queue_free()

func reset_dummy() -> void:
	current_health = max_health
	is_defeated = false
	update_health_display()
