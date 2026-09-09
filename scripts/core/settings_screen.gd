extends CodeBornScreen

func _ready() -> void:
	super._ready()
	var col: VBoxContainer = centered(620)
	UI.label(col,"SETTINGS",36,UI.CYAN)
	var feedback: Label = UI.label(col,"Saved automatically on this PC",16,UI.MUTED)
	for key: String in ["master","music","effects","brightness"]:
		var row: HBoxContainer = UI.row(col)
		UI.label(row,key.capitalize(),20).custom_minimum_size.x = 130
		var slider: HSlider = HSlider.new()
		slider.min_value = 0.6 if key == "brightness" else 0.0
		slider.max_value = 1.4 if key == "brightness" else 1.0
		slider.step = 0.05
		slider.value = SettingsManager.values[key]
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(slider)
		var number: Label = UI.label(row,"%d%%" % (slider.value*100),18)
		number.custom_minimum_size.x = 65
		slider.value_changed.connect(func(value: float) -> void:
			number.text = "%d%%" % (value*100)
			feedback.text = "Saved" if SettingsManager.save_value(key,value) == OK else "Could not save settings.")
	var full: CheckButton = CheckButton.new()
	full.text = "Fullscreen"
	full.button_pressed = SettingsManager.values.fullscreen
	full.toggled.connect(func(value: bool) -> void: SettingsManager.save_value("fullscreen",value))
	col.add_child(full)
	var resolution: OptionButton = OptionButton.new()
	resolution.add_item("1366 × 768")
	resolution.add_item("1920 × 1080")
	resolution.selected = SettingsManager.values.resolution
	resolution.item_selected.connect(func(index: int) -> void: SettingsManager.save_value("resolution",index))
	col.add_child(resolution)
	UI.paragraph(col,"Music and effects controls are ready for the team's audio assets. No music is bundled in this graybox.",16)
	UI.button(col,"Back",func() -> void: SceneRouter.go("menu"))
