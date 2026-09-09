extends Node

const SCREENS: Dictionary = {
	"menu": "res://scenes/ui/main_menu.tscn", "browser": "res://scenes/lobby/lan_browser.tscn",
	"lobby": "res://scenes/lobby/host_lobby.tscn", "reveal": "res://scenes/ui/role_reveal.tscn",
	"game": "res://scenes/gameplay/battle.tscn", "results": "res://scenes/ui/results.tscn",
	"settings": "res://scenes/ui/settings.tscn", "developer": "res://scenes/ui/developer.tscn"
}
var current: String = "menu"

func go(screen: String) -> void:
	if not SCREENS.has(screen):
		return
	current = screen
	get_tree().change_scene_to_file.call_deferred(SCREENS[screen])

func menu() -> void:
	NetworkManager.leave()
	go("menu")
