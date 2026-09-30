extends "res://scripts/ui/lan_lobby.gd"
@onready var service: Node = get_node("/root/OnlineSession")
func _ready() -> void:
 super._ready()
 service.match_started.connect(_enter_match)
 service.room_changed.connect(_room_update)
 service.status_changed.connect(_status)
 service.room_closed.connect(_disconnected)
 $HostRoom/Panel/Content/Invite/Copy.pressed.connect(_copy_code)
 $ConnectionOverlay/Center/Panel/Content/Apply.pressed.connect(_apply_connection)
 $ConnectionOverlay/Center/Panel/Content/Cancel.pressed.connect(func(): $ConnectionOverlay.hide())
 $Browser/Panel/Content/ListArea/CodeEntry/Code.text_submitted.connect(func(_text): _join())
 $Browser/Panel/Content/ListArea/Empty.hide()
 $Browser/Panel/Content/Count.text = "PRIVATE TWO-PLAYER ROOMS"
 $Browser/Panel/Content/Join.disabled = false
 ready_button.set_pressed_no_signal(false)
 _status("Create a room or enter the code your friend shared.")
 _update_start()
 if not service.room.is_empty(): _room_update(service.room)
func _host() -> void:
 service.create_room(_name(), preload("res://scripts/questions/deck_store.gd").active())
func _join() -> void:
 var code: String = $Browser/Panel/Content/ListArea/CodeEntry/Code.text.strip_edges().to_upper().replace(" ", "").replace("-", "")
 if code.length() != 6: _status("Enter the six-character room code."); return
 service.join_room(_name(), code)
func _refresh() -> void:
 $ConnectionOverlay/Center/Panel/Content/Address.text = service.endpoint
 $ConnectionOverlay.show()
func _apply_connection() -> void:
 if service.configure($ConnectionOverlay/Center/Panel/Content/Address.text):
  $ConnectionOverlay.hide()
  _status("Connection saved. Create a room or enter your friend's code.")
func _leave() -> void:
 service.leave(); _show_browser(); _status("You left the room.")
func _back() -> void:
 service.leave(); super._back()
func _show_browser() -> void:
 host_room.hide(); browser.show(); $DeckEditor.hide()
 $Header/Title.text = "ONLINE LOBBY"
 $Header/Subtitle.text = "CREATE A ROOM • SHARE A CODE • JOIN A FRIEND"
 guest_connected = false; guest_ready = false
 ready_button.set_pressed_no_signal(false)
func _disconnected(message: String) -> void:
 _show_browser(); _status(message)
func _status(message: String) -> void:
 $Browser/Panel/Content/Status.text = message
 if host_room.visible: $HostRoom/Panel/Content/Status.text = message
func _room_update(state: Dictionary) -> void:
 browser.hide(); host_room.show()
 var is_host: bool = service.player_id == str(state.host_id)
 $Header/Title.text = "HOST LOBBY" if is_host else "GAME LOBBY"
 $Header/Subtitle.text = "SHARE THE CODE WITH YOUR FRIEND" if is_host else "CONNECTED TO YOUR FRIEND'S ROOM"
 $HostRoom/Panel/Content/Invite/Code.text = str(state.code)
 $HostRoom/Questions.disabled = not is_host
 $HostRoom/Questions.text = "Astral deck: " + str(state.deck.name)
 guest_connected = state.players.size() == 2
 $HostRoom/Panel/Content/Heading/Count.text = "%d / 2 PLAYERS" % state.players.size()
 for index in 2:
  var base: String = "HostRoom/Panel/Content/Player%d/Row/Text/" % (index + 1)
  if index < state.players.size():
   var member: Dictionary = state.players[index]
   get_node(base + "Name").text = str(member.name) + (" (YOU)" if member.id == service.player_id else "")
   get_node(base + "Status").text = ("HOST • " if member.host else "GUEST • ") + ("READY" if member.ready else "NOT READY")
   if member.id == service.player_id:
    ready_button.set_pressed_no_signal(member.ready)
    ready_button.text = "✓ READY" if member.ready else "READY UP"
  else:
   get_node(base + "Name").text = "WAITING FOR PLAYER 2"
   get_node(base + "Status").text = "NOT CONNECTED"
 _update_start()
func _ready_changed(value: bool) -> void:
 if service.room.is_empty(): return
 service.set_ready(value)
func _update_start() -> void:
 var both_ready: bool = service.room.get("players", []).size() == 2
 for member in service.room.get("players", []): both_ready = both_ready and member.ready
 start_button.disabled = not (both_ready and service.is_host())
 start_button.text = "START MATCH" if service.is_host() else "HOST STARTS MATCH"
 $HostRoom/Panel/Content/Status.text = "Both players ready." if both_ready else "Share the code, choose your deck, and ready up."
func _start() -> void:
 if not start_button.disabled: service.start_match()
func _enter_match() -> void:
 get_tree().change_scene_to_file("res://scenes/network/online_match.tscn")
func _exit_tree() -> void:
 for pair in [[service.match_started, _enter_match], [service.room_changed, _room_update], [service.status_changed, _status], [service.room_closed, _disconnected]]:
  if pair[0].is_connected(pair[1]): pair[0].disconnect(pair[1])
func _deck_applied() -> void:
 if service.player_id == str(service.room.get("host_id", "")):
  service.update_deck(preload("res://scripts/questions/deck_store.gd").active())
func _copy_code() -> void:
 DisplayServer.clipboard_set(str(service.room.get("code", "")))
 _status("Room code copied. Share it with your friend.")

func _unhandled_key_input(event: InputEvent) -> void:
 if event.is_action_pressed("ui_cancel") and $ConnectionOverlay.visible:
  $ConnectionOverlay.hide()
  get_viewport().set_input_as_handled()
 else: super._unhandled_key_input(event)
