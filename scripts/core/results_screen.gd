extends CodeBornScreen

var rematch_button: Button

func _ready() -> void:
	super._ready()
	var col: VBoxContainer = centered(720)
	if MatchState.view.is_empty():
		UI.label(col,"Match interrupted",36)
		UI.button(col,"Main Menu",SceneRouter.menu)
		return
	var state: Dictionary = MatchState.view
	var won: bool = int(state.outcome.winner) == NetworkManager.local_id()
	var color: Color = UI.CYAN if won else Color("ff627b")
	UI.label(col,"VICTORY" if won else "DEFEAT",68,color).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.label(col,state.outcome.reason,24,color).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var pane: VBoxContainer = UI.panel(col)
	var wallet: Dictionary = state.wallets[NetworkManager.local_id()]
	UI.label(pane,"Code Core remaining: %s HP  •  Active play: %s s" % [state.base_hp,int(state.elapsed)],20)
	UI.label(pane,"Gold earned: %s     Gold spent: %s" % [wallet.earned,wallet.spent],20)
	UI.label(pane,"Questions answered: %s     Correct: %s" % [wallet.answered,wallet.correct],20)
	UI.label(pane,"Units trained: %s     Towers built: %s     Units defeated: %s" % [wallet.trained,wallet.built,wallet.killed],20)
	var button: Button = UI.button(col,"Rematch / Swap Roles",func() -> void: NetworkManager.vote_rematch())
	rematch_button = button
	button.disabled = NetworkManager.roster.size() != 2
	button.pressed.connect(func() -> void: button.text = "Waiting for opponent..."; button.disabled = true)
	NetworkManager.lobby_changed.connect(_roster_changed)
	UI.button(col,"Main Menu",SceneRouter.menu)

func _roster_changed() -> void:
	if NetworkManager.roster.size() != 2:
		rematch_button.text = "Opponent disconnected"
		rematch_button.disabled = true
