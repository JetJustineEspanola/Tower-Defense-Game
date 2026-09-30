extends Control
## All controls are authored in deck_editor.tscn. Notes are references, never executed.
signal deck_applied
const STORE = preload("res://scripts/questions/deck_store.gd")
var deck: Dictionary = {}
var selected: int = -1
var filling: bool = false

func _ready() -> void:
	deck = STORE.active()
	%Cards.item_selected.connect(_select)
	%Add.pressed.connect(_add)
	%Delete.pressed.connect(func(): %DeleteConfirm.popup_centered())
	%DeleteConfirm.confirmed.connect(_delete)
	%Save.pressed.connect(_save.bind(false))
	%Use.pressed.connect(_save.bind(true))
	%Close.pressed.connect(hide)
	%New.pressed.connect(_new)
	%Load.pressed.connect(_load_saved)
	%Type.item_selected.connect(func(_index): _type_visibility())
	%Attach.pressed.connect(func(): %NoteDialog.popup_centered(Vector2i(850, 550)))
	%NoteDialog.file_selected.connect(_attach)
	%OpenNote.pressed.connect(_open_note)
	%RemoveNote.pressed.connect(_remove_note)
	%Preview.pressed.connect(_preview)
	%Check.pressed.connect(_check)
	%Import.pressed.connect(func(): %ImportDialog.popup_centered(Vector2i(850, 550)))
	%ImportDialog.file_selected.connect(_import)
	%ImportQuestions.pressed.connect(func(): %QuestionImport.popup_centered())
	%QuestionImport.cards_imported.connect(_append_imported)
	_refresh()

func _refresh() -> void:
	%DeckName.text = str(deck.name)
	for i in 3: get_node("%Enable" + str(i)).button_pressed = STORE.TYPES[i] in deck.enabled_types
	selected = -1
	_list_cards()
	_select(0)
	_notes()
	%Saved.clear()
	DirAccess.make_dir_recursive_absolute(STORE.DIRECTORY)
	for file in DirAccess.get_files_at(STORE.DIRECTORY):
		if file.ends_with(".json"):
			var path: String = STORE.DIRECTORY.path_join(file)
			var saved: Dictionary = STORE.load_file(path)
			if not saved.is_empty():
				%Saved.add_item(str(saved.name))
				%Saved.set_item_metadata(%Saved.item_count - 1, path)

func _list_cards() -> void:
	%Cards.clear()
	for card in deck.cards:
		%Cards.add_item(str(card.prompt).left(48))
		%Cards.set_item_tooltip(%Cards.item_count - 1, str(card.type).replace("_", " ").capitalize() + "\n" + str(card.prompt))
	%CardsLabel.text = "YOUR QUESTIONS  •  " + str(deck.cards.size())
	if selected >= 0 and selected < deck.cards.size(): %Cards.select(selected)

func _commit() -> void:
	if selected < 0 or filling: return
	var card: Dictionary = deck.cards[selected]
	card.type = STORE.TYPES[%Type.selected]
	card.prompt = %Prompt.text
	card.code = %Code.text
	card.choices = [%ChoiceA.text, %ChoiceB.text, %ChoiceC.text, %ChoiceD.text]
	card.correct = %Correct.selected
	card.answers = Array(%Accepted.text.split("\n---\n", false))
	card.reward = int(%Gold.value)
	card.explanation = %Explanation.text
	deck.name = %DeckName.text
	deck.enabled_types = []
	for i in 3:
		if get_node("%Enable" + str(i)).button_pressed: deck.enabled_types.append(STORE.TYPES[i])

func _select(index: int) -> void:
	_commit()
	selected = index
	filling = true
	var card: Dictionary = deck.cards[index]
	%Type.select(STORE.TYPES.find(card.type))
	%Prompt.text = str(card.prompt)
	%Code.text = str(card.get("code", ""))
	var choices: Array = card.get("choices", ["", "", "", ""])
	for i in 4: get_node("%Choice" + "ABCD"[i]).text = str(choices[i]) if i < choices.size() else ""
	%Correct.select(int(card.get("correct", 0)))
	%Accepted.text = "\n---\n".join(card.get("answers", []))
	%Gold.value = int(card.get("reward", 25))
	%Explanation.text = str(card.get("explanation", ""))
	filling = false
	_list_cards()
	_type_visibility()
	_preview()

func _type_visibility() -> void:
	%Multiple.visible = %Type.selected == 0
	%Typed.visible = %Type.selected != 0
	%Code.visible = %Type.selected == 2
	%CodeLabel.visible = %Type.selected == 2
	%AnswerHelp.text = "Accepted answers • separate alternatives with --- on a new line.\nCapital letters and extra spaces are ignored." if %Type.selected == 1 else "Accepted code • separate alternatives with --- on a new line.\nCapital letters and spacing must match."

func _add() -> void:
	_commit()
	deck.cards.append({"id": str(Time.get_unix_time_from_system()) + "_" + str(Time.get_ticks_usec()), "type": "identification", "prompt": "New question", "answers": ["Answer"], "code": "", "choices": ["A", "B", "C", "D"], "correct": 0, "reward": 25, "explanation": ""})
	_select(deck.cards.size() - 1)

func _delete() -> void:
	if deck.cards.size() <= 1:
		%Status.text = "Keep at least one card."
		return
	deck.cards.remove_at(selected)
	selected = -1
	_select(0)

func _save(apply: bool) -> void:
	_commit()
	var error: String = STORE.save_deck(deck, apply)
	%Status.text = error if not error.is_empty() else "Saved locally." + (" Selected for matches; both players must ready up again." if apply else "")
	if error.is_empty():
		if apply: deck_applied.emit()
		_refresh()

func _new() -> void:
	_commit()
	if not STORE.valid(deck).is_empty():
		%Status.text = "Save a valid draft before creating another deck."
		return
	var error: String = STORE.save_deck(deck, false)
	if not error.is_empty():
		%Status.text = error
		return
	deck = {"version": 1, "id": str(Time.get_ticks_usec()), "name": "New deck", "cards": [], "notes": [], "enabled_types": STORE.TYPES.duplicate()}
	%DeckName.text = "New deck"
	for i in 3: get_node("%Enable" + str(i)).button_pressed = true
	selected = -1
	_add()
	_refresh()

func _load_saved() -> void:
	if %Saved.selected < 0: return
	_import(str(%Saved.get_item_metadata(%Saved.selected)))

func _import(path: String) -> void:
	var loaded: Dictionary = STORE.load_file(path)
	if loaded.is_empty():
		%Status.text = "Cannot load: invalid question deck or file exceeds 2 MB."
		return
	_commit()
	var error: String = STORE.save_deck(deck, false)
	if not error.is_empty():
		%Status.text = "Fix your current draft before loading: " + error
		return
	deck = loaded
	_refresh()
	%Status.text = "Loaded. Review the answers, then Save & use."

func _attach(path: String) -> void:
	if not path.get_extension().to_lower() in ["pdf", "docx", "txt"]: return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 20000000:
		%Status.text = "Choose a readable PDF, DOCX or TXT below 20 MB."
		return
	var bytes: PackedByteArray = file.get_buffer(file.get_length())
	DirAccess.make_dir_recursive_absolute("user://astral_notes")
	var target: String = "user://astral_notes/" + str(Time.get_ticks_usec()) + "_" + path.get_file()
	var output := FileAccess.open(target, FileAccess.WRITE)
	if output == null:
		%Status.text = "Could not copy the reference notes."
		return
	output.store_buffer(bytes)
	output.close()
	if not deck.has("notes"): deck.notes = []
	deck.notes.append({"name": path.get_file(), "path": target})
	_notes()
	%Status.text = "Reference attached. Open it beside the editor and create cards manually."

func _notes() -> void:
	%Notes.clear()
	for note in deck.get("notes", []): %Notes.add_item(str(note.name))

func _open_note() -> void:
	var items: PackedInt32Array = %Notes.get_selected_items()
	if items.is_empty(): return
	var path: String = str(deck.notes[items[0]].path)
	# Imported decks may only open copied reference documents in the notes directory.
	if path.begins_with("user://astral_notes/") and not ".." in path and path.get_extension().to_lower() in ["pdf", "docx", "txt"] and FileAccess.file_exists(path):
		OS.shell_open(ProjectSettings.globalize_path(path))
	else: %Status.text = "Reference unavailable on this computer. Attach it again."

func _remove_note() -> void:
	var items: PackedInt32Array = %Notes.get_selected_items()
	if items.is_empty(): return
	deck.notes.remove_at(items[0])
	_notes()

func _preview() -> void:
	_commit()
	var card: Dictionary = deck.cards[selected]
	%PreviewText.text = str(card.prompt) + "\n" + str(card.code)
	if card.type == "multiple_choice":
		for i in 4: %PreviewText.text += "\n%s. %s" % ["ABCD"[i], card.choices[i]]
	%PreviewAnswer.text = ""
	%PreviewChoice.visible = card.type == "multiple_choice"
	%PreviewAnswer.visible = card.type != "multiple_choice"
	%PreviewChoice.select(0)
	for i in 4:
		%PreviewChoice.set_item_text(i, "%s. %s" % ["ABCD"[i], str(card.choices[i]).left(30)] if card.type == "multiple_choice" else "ABCD"[i])
	%PreviewAnswer.placeholder_text = "Enter A, B, C or D" if card.type == "multiple_choice" else "Try an answer"
	%PreviewResult.text = "Preview only — no gold awarded."

func _check() -> void:
	_commit()
	var card: Dictionary = deck.cards[selected]
	var correct: bool = STORE.matches(card, %PreviewAnswer.text, %PreviewChoice.selected)
	%PreviewResult.text = ("Correct. " if correct else "Not accepted. ") + str(card.explanation)

func _append_imported(imported: Dictionary) -> void:
	_commit()
	if deck.cards.size() + imported.cards.size() > 500:
		%Status.text = "A deck can contain up to 500 questions."
		return
	var first: int = deck.cards.size()
	for source in imported.cards:
		var card: Dictionary = source.duplicate(true)
		card.id = "import_%s_%s" % [Time.get_ticks_usec(), deck.cards.size()]
		deck.cards.append(card)
		if not card.type in deck.enabled_types: deck.enabled_types.append(card.type)
	_refresh()
	_select(first)
	%Status.text = "%d questions added. Review the answers, then Save or Use this deck." % imported.cards.size()
