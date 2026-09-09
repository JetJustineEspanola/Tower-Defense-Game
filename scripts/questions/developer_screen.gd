extends CodeBornScreen

func _ready() -> void:
	super._ready()
	var col: VBoxContainer = page("ARCANE WORKSHOP", "Offline question authoring  /  GDScript 4.6  /  Changes require matching packs on both PCs")
	UI.paragraph(col,"Edit the JSON below to add or change Coding Fix, Multiple Choice, and Identification questions. Difficulty: easy, medium, hard. Reward: 1–60 gold. Coding Fix uses one ___ blank; answers are compared as text and never executed.",16)
	var editor: TextEdit = TextEdit.new()
	editor.text = JSON.stringify(QuestionRepository.questions,"\t")
	editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor.add_theme_font_size_override("font_size",16)
	col.add_child(editor)
	var feedback: Label = UI.paragraph(col,"Local file: user://questions.json",18,UI.CYAN)
	var row: HBoxContainer = UI.row(col)
	UI.button(row,"Validate",func() -> void:
		var problem: String = QuestionRepository.validate_pack(JSON.parse_string(editor.text))
		feedback.text = "Valid pack. Ready to save." if problem.is_empty() else problem)
	UI.button(row,"Save locally",func() -> void:
		var problem: String = QuestionRepository.save_pack(editor.text)
		feedback.text = "Saved. Share this exact pack with your opponent before hosting." if problem.is_empty() else problem)
	UI.button(row,"Add question",func() -> void:
		var data: Variant = JSON.parse_string(editor.text)
		if not data is Array:
			feedback.text = "Fix invalid JSON before adding a question."
			return
		data.append({"id":"new-"+str(Time.get_ticks_msec()),"type":"identification","difficulty":"easy","language":"GDScript","language_version":"4.6","prompt":"Write your prompt here","answers":["answer"],"reward":25,"explanation":"Explain the answer here"})
		editor.text = JSON.stringify(data,"\t"))
	UI.button(row,"Back",func() -> void: SceneRouter.go("menu"))
