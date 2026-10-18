extends Node3D

@onready var player: CharacterBody3D = $Player

var _objective_label: Label
var _status_label: Label
var _relics: Array[Area3D] = []
var _relics_found := 0
var _status_time := 0.0

func _ready() -> void:
	for pickup in get_tree().get_nodes_in_group("relic_pickups"):
		if pickup is Area3D:
			_relics.append(pickup as Area3D)
	_build_hud()
	_update_objective()
	if _relics.is_empty():
		_show_status("The ruins are silent. No relics were found in this scene.", 5.0)
	else:
		_show_status("Explore the ruins and recover all three ancient shards.", 4.0)

func _process(delta: float) -> void:
	if _status_time > 0.0:
		_status_time -= delta
		if _status_time <= 0.0:
			if _relics_found >= 3:
				_status_label.text = "Area secured. More of the lost world awaits."
			else:
				_status_label.text = "Move with the arrows • Press E near a glowing shard"
	if _relics_found >= 3:
		return
	if Input.is_action_just_pressed("interact"):
		_try_collect_nearest_relic()

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "GameHUD"
	add_child(hud)

	_objective_label = Label.new()
	_objective_label.position = Vector2(22.0, 18.0)
	_objective_label.size = Vector2(680.0, 48.0)
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

func _update_objective() -> void:
	_objective_label.text = "THE LOST RELICS   •   Shards %d / 3" % _relics_found

func _try_collect_nearest_relic() -> void:
	var nearest: Area3D = null
	var nearest_distance := 3.5
	for pickup in _relics:
		if not is_instance_valid(pickup):
			continue
		var distance := player.global_position.distance_to(pickup.global_position)
		if distance <= nearest_distance:
			nearest = pickup
			nearest_distance = distance
	if nearest == null:
		_show_status("No shard nearby. Search around the ancient stones.", 1.8)
		return

	var shard_name := "Ancient shard"
	if nearest.get("display_name") != null:
		shard_name = str(nearest.get("display_name"))
	_relics.erase(nearest)
	nearest.queue_free()
	_relics_found += 1
	_update_objective()
	if _relics_found >= 3:
		_show_status("All shards recovered. The ruins reveal their secret.", 4.0)
	else:
		_show_status("%s recovered. Keep exploring." % shard_name, 2.5)

func _show_status(message: String, duration: float) -> void:
	_status_label.text = message
	_status_time = duration
