extends CodeBornScreen

func _ready() -> void:
	super._ready()
	var col: VBoxContainer = centered(390)
	var eyebrow: Label = UI.label(col,"ARCANE SYSTEMS  /  LAN DUEL",16,UI.PURPLE)
	eyebrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var logo: Label = UI.label(col,"CODE BORN",64,UI.CYAN)
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sub: Label = UI.label(col,"Build your defense. Rewrite the outcome.",16,UI.MUTED)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.label(col,"")
	UI.button(col,"PLAY",func() -> void: SceneRouter.go("browser")).grab_focus()
	UI.button(col,"Settings",func() -> void: SceneRouter.go("settings"))
	UI.button(col,"Developer",func() -> void: SceneRouter.go("developer"))
	UI.button(col,"Quit",func() -> void: get_tree().quit())
	var footer: Label = UI.label(self,"CODEBORN " + AppState.BUILD + "  •  GODOT 4.6  •  TWO PLAYERS / ONE NETWORK",14,UI.MUTED)
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	footer.position = Vector2(48,size.y-58)
