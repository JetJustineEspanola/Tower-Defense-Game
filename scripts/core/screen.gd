class_name CodeBornScreen
extends Control

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UI.theme()
	resized.connect(queue_redraw)
	SettingsManager.changed.connect(queue_redraw)

func _draw() -> void:
	var brightness: float = SettingsManager.values.brightness
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.025,0.035,0.08)*brightness)
	for i: int in range(24):
		var x: float = float(i) * size.x / 23.0
		draw_line(Vector2(x,0),Vector2(x-size.y*0.3,size.y),Color(0.1,0.35,0.6,0.09),1)
	var center: Vector2 = size * Vector2(0.5,0.44)
	for radius: float in [230.0, 260.0, 390.0]:
		draw_arc(center,radius*size.y/768.0,0.2,5.7,80,Color(0.25,0.45,0.9,0.17),1.5,true)
	for i: int in range(70):
		var p: Vector2 = Vector2(fmod(i*157.3,size.x),fmod(i*97.7,size.y))
		draw_circle(p,1.2,Color(0.35,0.6,1.0,0.25))
	for corner: Vector2 in [Vector2(24,24),Vector2(size.x-24,24),Vector2(24,size.y-24),size-Vector2(24,24)]:
		var sign_x: float = 1.0 if corner.x < size.x/2 else -1.0
		var sign_y: float = 1.0 if corner.y < size.y/2 else -1.0
		draw_line(corner,corner+Vector2(64*sign_x,0),UI.CYAN,2)
		draw_line(corner,corner+Vector2(0,38*sign_y),UI.PURPLE,2)

func centered(width: float = 580) -> VBoxContainer:
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var col: VBoxContainer = UI.column(center)
	col.custom_minimum_size.x = width
	return col

func page(title: String, subtitle: String) -> VBoxContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+side,48)
	add_child(margin)
	var col: VBoxContainer = UI.column(margin)
	UI.label(col,title,34,UI.CYAN)
	UI.paragraph(col,subtitle)
	return col
