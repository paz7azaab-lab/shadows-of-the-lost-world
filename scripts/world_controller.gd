extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var relic: Area3D = $AncientRelic

var _objective_label: Label
var _status_label: Label
var _relic_found := false
var _status_time := 0.0

func _ready() -> void:
	_build_hud()
	_objective_label.text = "OBJECTIVE  •  Find the lost relic"
	_status_label.text = "Explore the forest. The ruins lie beyond the trees."

func _process(delta: float) -> void:
	if _status_time > 0.0:
		_status_time -= delta
		if _status_time <= 0.0 and not _relic_found:
			_status_label.text = "Move with the arrows • Press E near the relic"
	if _relic_found:
		return
	if Input.is_action_just_pressed("interact"):
		if player.global_position.distance_to(relic.global_position) <= 3.5:
			_collect_relic()
		else:
			_show_status("Nothing to interact with nearby.", 1.8)

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "GameHUD"
	add_child(hud)

	_objective_label = Label.new()
	_objective_label.position = Vector2(22.0, 18.0)
	_objective_label.size = Vector2(600.0, 42.0)
	_objective_label.add_theme_font_size_override("font_size", 22)
	_objective_label.add_theme_color_override("font_color", Color(0.98, 0.91, 0.70))
	_objective_label.add_theme_color_override("font_shadow_color", Color(0.02, 0.05, 0.03, 0.9))
	_objective_label.add_theme_constant_override("shadow_offset_x", 2)
	_objective_label.add_theme_constant_override("shadow_offset_y", 2)
	hud.add_child(_objective_label)

	_status_label = Label.new()
	_status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_status_label.position = Vector2(0.0, -64.0)
	_status_label.size = Vector2(900.0, 40.0)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 17)
	_status_label.add_theme_color_override("font_color", Color(0.94, 0.96, 0.88))
	hud.add_child(_status_label)

func _collect_relic() -> void:
	_relic_found = true
	relic.visible = false
	relic.monitoring = false
	_objective_label.text = "OBJECTIVE COMPLETE  •  Lost relic recovered"
	_show_status("The ancient relic hums with a forgotten light.", 4.0)

func _show_status(message: String, duration: float) -> void:
	_status_label.text = message
	_status_time = duration
