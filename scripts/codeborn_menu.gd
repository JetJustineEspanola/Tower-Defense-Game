extends Control

@onready var main_menu: Control = $MainMenu
@onready var play_screen: Control = $PlayScreen
@onready var settings_screen: Control = $SettingsScreen
@onready var developer_screen: Control = $DeveloperScreen
@onready var volume_slider: HSlider = $SettingsScreen/CenterContainer/PanelContainer/Content/VolumeSlider

func _ready() -> void:
	$MainMenu/CenterContainer/PanelContainer/Content/Buttons/PlayButton.pressed.connect(_show_play_screen)
	$MainMenu/CenterContainer/PanelContainer/Content/Buttons/SettingsButton.pressed.connect(_show_settings_screen)
	$MainMenu/CenterContainer/PanelContainer/Content/Buttons/DeveloperButton.pressed.connect(_show_developer_screen)
	$MainMenu/CenterContainer/PanelContainer/Content/Buttons/QuitButton.pressed.connect(_quit_game)
	$PlayScreen/CenterContainer/PanelContainer/Content/BackButton.pressed.connect(_show_main_menu)
	$SettingsScreen/CenterContainer/PanelContainer/Content/BackButton.pressed.connect(_show_main_menu)
	$DeveloperScreen/CenterContainer/PanelContainer/Content/BackButton.pressed.connect(_show_main_menu)
	_show_main_menu()

func _show_main_menu() -> void:
	main_menu.show()
	play_screen.hide()
	settings_screen.hide()
	developer_screen.hide()

func _show_play_screen() -> void:
	_show_screen(play_screen)

func _show_settings_screen() -> void:
	_show_screen(settings_screen)

func _show_developer_screen() -> void:
	_show_screen(developer_screen)

func _show_screen(screen: Control) -> void:
	main_menu.hide()
	play_screen.hide()
	settings_screen.hide()
	developer_screen.hide()
	screen.show()

func _quit_game() -> void:
	get_tree().quit()
