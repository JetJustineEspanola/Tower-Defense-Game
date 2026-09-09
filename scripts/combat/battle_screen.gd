extends CodeBornScreen

var hud: Label
var phase_label: Label
var purchase: Button
var selection: Label
var feedback: Label
var queue_label: Label
var question_label: Label
var answer: LineEdit
var battlefield: BattlefieldView
var ability_buttons: Dictionary = {}
var selected_node: int = -1
var attacking: bool = false
var pending: Dictionary = {}
var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/data/catalog.json"))

func _ready() -> void:
	super._ready()
	attacking = NetworkManager.local_id() == NetworkManager.attacker
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left","right","top","bottom"]:
		margin.add_theme_constant_override("margin_"+side,24)
	add_child(margin)
	var col: VBoxContainer = UI.column(margin)
	hud = UI.label(col,"Synchronizing battlefield...",22,UI.CYAN)
	phase_label = UI.label(col,"",16,UI.MUTED)
	var center: HBoxContainer = UI.row(col)
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var map_col: VBoxContainer = UI.column(center)
	map_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var container: SubViewportContainer = SubViewportContainer.new()
	container.stretch = true
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_col.add_child(container)
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(960,500)
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	battlefield = load("res://scenes/maps/arcane_crossing.tscn").instantiate()
	viewport.add_child(battlefield)
	battlefield.node_selected.connect(func(id: int) -> void: selected_node=id; _refresh())
	var map_controls: HBoxContainer = UI.row(map_col)
	UI.button(map_controls,"Zoom +",func() -> void: battlefield.change_zoom(-0.05))
	UI.button(map_controls,"Zoom −",func() -> void: battlefield.change_zoom(0.05))
	UI.label(map_controls,"Fixed isometric  /  Click a numbered node",14,UI.MUTED)
	var side: VBoxContainer = UI.panel(center)
	side.add_theme_constant_override("separation",8)
	side.get_parent().custom_minimum_size.x = 300
	side.get_parent().custom_minimum_size.y = 0
	UI.label(side,"ARCANE QUESTIONS",20,UI.PURPLE)
	UI.paragraph(side,"Answer to earn gold. Play stays live.",15)
	var question_scroll: ScrollContainer = ScrollContainer.new()
	question_scroll.custom_minimum_size.y = 90
	question_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	question_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side.add_child(question_scroll)
	question_label = UI.paragraph(question_scroll,"Generate a question to begin.",16)
	answer = UI.input(side,"Your answer")
	answer.max_length = 500
	UI.button(side,"Generate / %s Mana" % int(catalog.rules.question_cost),func() -> void: _request("question"))
	UI.button(side,"Submit answer",func() -> void: _request("answer",{"answer":answer.text}); answer.clear())
	UI.label(side,"Prototype pack • %s questions" % QuestionRepository.questions.size(),14,UI.MUTED)
	var shop: VBoxContainer = UI.panel(col)
	var controls: HBoxContainer = UI.row(shop)
	var definition: Dictionary = catalog.troops.core_runner if attacking else catalog.towers.pulse_spire
	purchase = UI.button(controls,"%s  /  %s Gold" % [definition.name,int(definition.cost)],func() -> void: _request("train" if attacking else "build",{} if attacking else {"node":selected_node}))
	selection = UI.label(controls,"",16,UI.CYAN)
	selection.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	UI.button(controls,"Surrender",_confirm_surrender)
	queue_label = UI.label(shop,"",16,UI.MUTED)
	var upgrades: HBoxContainer = UI.row(shop)
	for ability: String in definition.abilities:
		var button: Button = UI.button(upgrades,catalog.abilities[ability].name,func() -> void: _request("ability",{"ability":ability,"node":selected_node}))
		button.add_theme_font_size_override("font_size",14)
		button.custom_minimum_size.y = 38
		button.tooltip_text = catalog.abilities[ability].description
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ability_buttons[ability] = button
	feedback = UI.label(col,"Select a card to issue a command.",16,UI.CYAN)
	MatchState.updated.connect(_refresh)
	MatchState.command_result.connect(_ack)
	_refresh()

func _request(action: String, payload: Dictionary = {}) -> void:
	feedback.text = "Request pending..."
	# Register before dispatch because host acknowledgments are synchronous.
	pending[MatchState.sequence+1] = action
	MatchState.request(action,payload)

func _ack(sequence: int, message: String) -> void:
	pending.erase(sequence)
	feedback.text = message

func _confirm_surrender() -> void:
	var dialog: ConfirmationDialog = ConfirmationDialog.new()
	dialog.dialog_text = "Surrender this match? Your opponent will win."
	dialog.title = "Surrender"
	add_child(dialog)
	dialog.confirmed.connect(func() -> void: _request("surrender"); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered()

func _refresh() -> void:
	var state: Dictionary = MatchState.view
	if state.is_empty() or not state.wallets.has(NetworkManager.local_id()):
		return
	var wallet: Dictionary = state.wallets[NetworkManager.local_id()]
	var seconds: int = ceili(float(state.remaining))
	hud.text = "%s   /   CORE %s HP      %02d:%02d      GOLD %s      MANA %s" % ["ATTACKER" if attacking else "DEFENDER",state.base_hp,seconds/60,seconds%60,wallet.gold,wallet.mana]
	phase_label.text = "PREPARATION  /  %s seconds  /  Training and combat frozen" % ceili(float(state.phase_left)) if state.phase == "preparation" else "LAN CONNECTED  /  Live play — no pause"
	var selected_abilities: Array = state.blueprint_abilities if attacking else []
	if attacking:
		selection.text = "Core Runner blueprint  /  %s of 2 abilities" % selected_abilities.size()
		var orders: PackedStringArray = []
		for i: int in range(state.orders.size()):
			orders.append("Lane %s: %ss" % [i+1,ceili(float(state.orders[i].remaining))] if i < 2 else "Queued")
		queue_label.text = "Training: " + ("ready for orders" if orders.is_empty() else "  •  ".join(orders)) + "  |  Abilities affect future orders only"
	else:
		if selected_node >= 0 and state.towers.has(selected_node):
			selected_abilities = state.towers[selected_node].abilities
		selection.text = "Choose a deployment node" if selected_node < 0 else "Node %02d  /  %s" % [selected_node+1,"Pulse Spire — %s of 2 abilities" % selected_abilities.size() if state.towers.has(selected_node) else "Available"]
		queue_label.text = "%s fixed nodes  /  Target: enemy nearest the core  /  Ability slots: %s then %s Gold" % [battlefield.map.nodes.size(),int(catalog.ability_costs.tower[0]),int(catalog.ability_costs.tower[1])]
	for ability: String in ability_buttons:
		var button: Button = ability_buttons[ability]
		button.text = ("✓ " if ability in selected_abilities else "") + str(catalog.abilities[ability].name)
		button.disabled = ability in selected_abilities or selected_abilities.size() >= 2 or not catalog.abilities[ability].get("enabled",true) or (not attacking and not state.towers.has(selected_node))
	var question: Dictionary = state.questions.get(NetworkManager.local_id(),{})
	if question.is_empty():
		question_label.text = "Generate a question to earn gold.\n\nCoding Fix answers replace only the marked blank."
	else:
		question_label.text = "%s  /  %s Gold\n\n%s" % [str(question.difficulty).capitalize(),int(question.reward),question.prompt]
		if question.has("options"):
			question_label.text += "\n\n" + "\n".join(question.options)
