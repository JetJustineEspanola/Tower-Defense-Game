class_name UI
extends RefCounted

const CYAN: Color = Color("68e3ff")
const MUTED: Color = Color("a2b2cf")
const PURPLE: Color = Color("ab83ff")

static func style(color: Color = Color("0d1830"), border: Color = Color("275679")) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(8)
	box.content_margin_left = 20
	box.content_margin_right = 20
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	return box

static func theme() -> Theme:
	var result: Theme = Theme.new()
	result.default_font_size = 18
	result.set_color("font_color", "Label", Color("e5eeff"))
	result.set_color("font_color", "Button", Color("d2eaff"))
	result.set_color("font_hover_color", "Button", Color.WHITE)
	result.set_stylebox("normal", "Button", style())
	result.set_stylebox("hover", "Button", style(Color("163553"), CYAN))
	result.set_stylebox("pressed", "Button", style(Color("233760"), PURPLE))
	result.set_stylebox("focus", "Button", style(Color(0,0,0,0),CYAN))
	result.set_stylebox("disabled", "Button", style(Color("101729"),Color("263349")))
	result.set_color("font_disabled_color","Button",Color("718099"))
	result.set_stylebox("panel", "PanelContainer", style())
	result.set_stylebox("normal", "LineEdit", style(Color("060e20")))
	result.set_stylebox("focus", "LineEdit", style(Color("060e20"),CYAN))
	result.set_stylebox("normal", "TextEdit", style(Color("060e20")))
	result.set_stylebox("normal", "ItemList", style(Color("060e20")))
	result.set_constant("separation","VBoxContainer",12)
	result.set_constant("separation","HBoxContainer",12)
	return result

static func label(parent: Node, text: String, size: int = 18, color: Color = Color("e5eeff")) -> Label:
	var node: Label = Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size",size)
	node.add_theme_color_override("font_color",color)
	parent.add_child(node)
	return node

static func paragraph(parent: Node, text: String, size: int = 18, color: Color = MUTED) -> Label:
	var node: Label = label(parent,text,size,color)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return node

static func button(parent: Node, text: String, action: Callable) -> Button:
	var node: Button = Button.new()
	node.text = text
	node.custom_minimum_size.y = 46
	node.pressed.connect(action)
	parent.add_child(node)
	return node

static func input(parent: Node, placeholder: String, text: String = "") -> LineEdit:
	var node: LineEdit = LineEdit.new()
	node.placeholder_text = placeholder
	node.text = text
	node.custom_minimum_size.y = 44
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(node)
	return node

static func column(parent: Node) -> VBoxContainer:
	var node: VBoxContainer = VBoxContainer.new()
	parent.add_child(node)
	return node

static func row(parent: Node) -> HBoxContainer:
	var node: HBoxContainer = HBoxContainer.new()
	parent.add_child(node)
	return node

static func panel(parent: Node) -> VBoxContainer:
	var frame: PanelContainer = PanelContainer.new()
	parent.add_child(frame)
	return column(frame)

static func spacer(parent: Node) -> Control:
	var node: Control = Control.new()
	node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(node)
	return node
