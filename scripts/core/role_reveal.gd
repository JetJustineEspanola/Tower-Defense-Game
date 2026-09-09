extends CodeBornScreen

var clock_label: Label

func _ready() -> void:
	super._ready()
	var col: VBoxContainer = centered(660)
	UI.label(col,"THE CODE HAS CHOSEN",22,UI.PURPLE).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var attacking: bool = NetworkManager.local_id() == NetworkManager.attacker
	UI.label(col,"ATTACKER" if attacking else "DEFENDER",64,UI.CYAN).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.paragraph(col,"Train Core Runners and destroy the Code Core." if attacking else "Build Pulse Spires and protect the Code Core until time expires.",24).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_label = UI.label(col,"Synchronizing players...",28)
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	NetworkManager.reveal_changed.connect(_refresh)
	NetworkManager.acknowledge_scene.call_deferred()

func _refresh() -> void:
	clock_label.text = "Battlefield opens in %s" % ceili(NetworkManager.reveal_left)
