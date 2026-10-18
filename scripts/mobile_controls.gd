extends CanvasLayer

const BUTTON_SIZE := Vector2(54.0, 54.0)
var _held_actions: Array[StringName] = []

func _ready() -> void:
	_ensure_interact_action()
	var layer := Control.new()
	layer.name = "TouchControlLayer"
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(layer)

	_add_action_button(layer, "◀", &"ui_left", Vector2(22, -112), Control.PRESET_BOTTOM_LEFT)
	_add_action_button(layer, "▲", &"ui_up", Vector2(78, -166), Control.PRESET_BOTTOM_LEFT)
	_add_action_button(layer, "▼", &"ui_down", Vector2(78, -58), Control.PRESET_BOTTOM_LEFT)
	_add_action_button(layer, "▶", &"ui_right", Vector2(134, -112), Control.PRESET_BOTTOM_LEFT)
	_add_action_button(layer, "E", &"interact", Vector2(-86, -94), Control.PRESET_BOTTOM_RIGHT)

func _ensure_interact_action() -> void:
	if not InputMap.has_action(&"interact"):
		InputMap.add_action(&"interact")
	var event := InputEventKey.new()
	event.physical_keycode = KEY_E
	if not InputMap.action_has_event(&"interact", event):
		InputMap.action_add_event(&"interact", event)

func _add_action_button(parent: Control, label: String, action: StringName, offset: Vector2, preset: Control.LayoutPreset) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = BUTTON_SIZE
	button.size = BUTTON_SIZE
	button.set_anchors_preset(preset)
	button.position = offset
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(0.96, 0.94, 0.82))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.14, 0.12, 0.78)
	normal.border_color = Color(0.62, 0.72, 0.48, 0.9)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(14)
	button.add_theme_stylebox_override("normal", normal)
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.27, 0.42, 0.25, 0.95)
	pressed.border_color = Color(0.85, 0.88, 0.63, 1.0)
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(14)
	button.add_theme_stylebox_override("pressed", pressed)
	button.button_down.connect(_press_action.bind(action))
	button.button_up.connect(_release_action.bind(action))
	parent.add_child(button)

func _press_action(action: StringName) -> void:
	if not Input.is_action_pressed(action):
		Input.action_press(action)
	if not _held_actions.has(action):
		_held_actions.append(action)

func _release_action(action: StringName) -> void:
	Input.action_release(action)
	_held_actions.erase(action)

func _exit_tree() -> void:
	for action in _held_actions:
		Input.action_release(action)
