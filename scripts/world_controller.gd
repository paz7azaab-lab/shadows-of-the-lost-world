extends Node3D

@onready var player: CharacterBody3D = $Player

const RESOURCE_INTERACT_DISTANCE := 3.4
const HUNGER_TICK_SECONDS := 12.0
const STARTING_HEALTH := 100.0
const STARTING_HUNGER := 100.0

var _objective_label: Label
var _survival_label: Label
var _status_label: Label
var _relics: Array[Area3D] = []
var _relics_found := 0
var _health := STARTING_HEALTH
var _hunger := STARTING_HUNGER
var _wood := 0
var _stone := 0
var _hunger_clock := 0.0
var _status_time := 0.0
var _campfire_built := false
var _gatherables: Array[Node3D] = []

func _ready() -> void:
	for pickup in get_tree().get_nodes_in_group("relic_pickups"):
		if pickup is Area3D:
			_relics.append(pickup as Area3D)
	_spawn_gatherables()
	_build_hud()
	_update_hud()
	if _relics.is_empty():
		_show_status("The ruins are silent. No relics were found in this scene.", 5.0)
	else:
		_show_status("Explore, gather supplies, and recover all three ancient shards.", 5.0)

func _process(delta: float) -> void:
	_hunger_clock += delta
	if _hunger_clock >= HUNGER_TICK_SECONDS:
		_hunger_clock = 0.0
		_hunger = maxf(0.0, _hunger - 4.0)
		if _hunger <= 0.0:
			_health = maxf(0.0, _health - 5.0)
		_update_hud()
		if _health <= 0.0:
			_show_status("You are exhausted. Gather supplies and restart your expedition.", 3.0)

	if _status_time > 0.0:
		_status_time -= delta
		if _status_time <= 0.0:
			if _relics_found >= 3:
				_status_label.text = "All shards recovered • Keep exploring the lost world"
			else:
				_status_label.text = "Move with arrows • Tap E to gather, recover, or craft"

	if Input.is_action_just_pressed("interact"):
		_interact_with_world()

func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "GameHUD"
	add_child(hud)

	_objective_label = Label.new()
	_objective_label.position = Vector2(22.0, 14.0)
	_objective_label.size = Vector2(760.0, 38.0)
	_objective_label.add_theme_font_size_override("font_size", 22)
	_objective_label.add_theme_color_override("font_color", Color(0.98, 0.91, 0.70))
	hud.add_child(_objective_label)

	_survival_label = Label.new()
	_survival_label.position = Vector2(22.0, 52.0)
	_survival_label.size = Vector2(900.0, 34.0)
	_survival_label.add_theme_font_size_override("font_size", 17)
	_survival_label.add_theme_color_override("font_color", Color(0.82, 0.94, 0.79))
	hud.add_child(_survival_label)

	_status_label = Label.new()
	_status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_status_label.position = Vector2(0.0, -64.0)
	_status_label.size = Vector2(1000.0, 40.0)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_font_size_override("font_size", 17)
	_status_label.add_theme_color_override("font_color", Color(0.94, 0.96, 0.88))
	hud.add_child(_status_label)

func _update_hud() -> void:
	if is_instance_valid(_objective_label):
		_objective_label.text = "THE LOST RELICS   •   Shards %d / 3" % _relics_found
	if is_instance_valid(_survival_label):
		_survival_label.text = "HEALTH %d%%   •   HUNGER %d%%   •   WOOD %d   •   STONE %d" % [int(_health), int(_hunger), _wood, _stone]

func _spawn_gatherables() -> void:
	var wood_positions: Array[Vector3] = [
		Vector3(-7, 0, -2), Vector3(7, 0, 3), Vector3(-16, 0, -12),
		Vector3(17, 0, -8), Vector3(-20, 0, 13), Vector3(21, 0, 16)
	]
	var stone_positions: Array[Vector3] = [
		Vector3(-5, 0, -9), Vector3(8, 0, -12), Vector3(-14, 0, 5),
		Vector3(15, 0, -21), Vector3(24, 0, 4), Vector3(-25, 0, -20)
	]
	for point in wood_positions:
		var log := Node3D.new()
		log.name = "GatherableWood"
		log.set_meta("resource_type", "wood")
		log.position = point
		var mesh := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = 0.18
		cylinder.bottom_radius = 0.22
		cylinder.height = 1.5
		mesh.mesh = cylinder
		mesh.rotation_degrees.z = 90.0
		mesh.position.y = 0.24
		mesh.material_override = _make_resource_material(Color(0.40, 0.23, 0.12))
		log.add_child(mesh)
		add_child(log)
		_gatherables.append(log)
	for point in stone_positions:
		var rock := Node3D.new()
		rock.name = "GatherableStone"
		rock.set_meta("resource_type", "stone")
		rock.position = point
		var mesh := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.48
		sphere.height = 0.85
		mesh.mesh = sphere
		mesh.position.y = 0.32
		mesh.scale = Vector3(1.25, 0.8, 1.0)
		mesh.material_override = _make_resource_material(Color(0.48, 0.54, 0.53))
		rock.add_child(mesh)
		add_child(rock)
		_gatherables.append(rock)

func _make_resource_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material

func _interact_with_world() -> void:
	var nearest_relic: Area3D = null
	var nearest_relic_distance := RESOURCE_INTERACT_DISTANCE
	for pickup in _relics:
		if not is_instance_valid(pickup):
			continue
		var distance := player.global_position.distance_to(pickup.global_position)
		if distance <= nearest_relic_distance:
			nearest_relic = pickup
			nearest_relic_distance = distance
	if nearest_relic != null:
		_collect_relic(nearest_relic)
		return

	var nearest_resource: Node3D = null
	var nearest_resource_distance := RESOURCE_INTERACT_DISTANCE
	for resource in _gatherables:
		if not is_instance_valid(resource):
			continue
		var distance := player.global_position.distance_to(resource.global_position)
		if distance <= nearest_resource_distance:
			nearest_resource = resource
			nearest_resource_distance = distance
	if nearest_resource != null:
		_gather_resource(nearest_resource)
		return

	if not _campfire_built and _wood >= 5 and _stone >= 3:
		_craft_campfire()
	else:
		_show_status("Get close to a glowing shard or supply pile. Campfire: 5 wood + 3 stone.", 2.5)

func _collect_relic(relic: Area3D) -> void:
	var shard_name := "Ancient shard"
	if relic.get("display_name") != null:
		shard_name = str(relic.get("display_name"))
	_relics.erase(relic)
	relic.queue_free()
	_relics_found += 1
	_update_hud()
	if _relics_found >= 3:
		_show_status("All three shards recovered! The ruins' first secret is yours.", 4.0)
	else:
		_show_status("%s recovered. Keep exploring." % shard_name, 2.5)

func _gather_resource(resource: Node3D) -> void:
	var resource_type := str(resource.get_meta("resource_type", "wood"))
	if resource_type == "wood":
		_wood += 2
		_show_status("Gathered wood +2. Find stone to craft a campfire.", 2.0)
	else:
		_stone += 2
		_show_status("Gathered stone +2. Collect 5 wood and 3 stone for a campfire.", 2.0)
	_gatherables.erase(resource)
	resource.queue_free()
	_update_hud()

func _craft_campfire() -> void:
	_wood -= 5
	_stone -= 3
	_campfire_built = true
	var fire := Node3D.new()
	fire.name = "CraftedCampfire"
	fire.position = player.global_position + Vector3(0.0, 0.0, -2.0)
	var glow := MeshInstance3D.new()
	var orb := SphereMesh.new()
	orb.radius = 0.48
	orb.height = 0.96
	glow.mesh = orb
	glow.position.y = 0.6
	var fire_material := StandardMaterial3D.new()
	fire_material.albedo_color = Color(1.0, 0.38, 0.08)
	fire_material.emission_enabled = true
	fire_material.emission = Color(1.0, 0.18, 0.025)
	glow.material_override = fire_material
	fire.add_child(glow)
	add_child(fire)
	_hunger = minf(100.0, _hunger + 35.0)
	_update_hud()
	_show_status("Campfire crafted! Hunger restored by 35. Supplies are spent.", 3.0)

func _show_status(message: String, duration: float) -> void:
	_status_label.text = message
	_status_time = duration
