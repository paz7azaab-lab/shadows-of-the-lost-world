extends Node3D

@export var tree_count: int = 42
@export var forest_radius: float = 34.0

var _rng := RandomNumberGenerator.new()
var _bark_material: StandardMaterial3D
var _leaf_materials: Array[StandardMaterial3D] = []
var _stone_material: StandardMaterial3D

func _ready() -> void:
	_rng.randomize()
	_bark_material = _make_material(Color(0.25, 0.14, 0.08))
	_stone_material = _make_material(Color(0.42, 0.47, 0.43))
	_leaf_materials = [
		_make_material(Color(0.12, 0.34, 0.20)),
		_make_material(Color(0.18, 0.42, 0.24)),
		_make_material(Color(0.24, 0.39, 0.19))
	]
	_spawn_trees()
	_spawn_ruins()
	_spawn_rocks()

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	return material

func _spawn_trees() -> void:
	for i in range(tree_count):
		var x := _rng.randf_range(-forest_radius, forest_radius)
		var z := _rng.randf_range(-forest_radius, forest_radius)
		if Vector2(x, z).length() < 6.0:
			continue
		var tree := Node3D.new()
		tree.position = Vector3(x, 0.0, z)
		add_child(tree)

		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = 0.20
		trunk_mesh.bottom_radius = 0.34
		trunk_mesh.height = _rng.randf_range(2.2, 3.3)
		var trunk := MeshInstance3D.new()
		trunk.mesh = trunk_mesh
		trunk.material_override = _bark_material
		trunk.position.y = trunk_mesh.height * 0.5
		tree.add_child(trunk)

		var crown_mesh := SphereMesh.new()
		crown_mesh.radius = _rng.randf_range(1.0, 1.5)
		crown_mesh.height = crown_mesh.radius * 2.0
		var crown := MeshInstance3D.new()
		crown.mesh = crown_mesh
		crown.material_override = _leaf_materials[_rng.randi_range(0, _leaf_materials.size() - 1)]
		crown.position.y = trunk_mesh.height + 0.35
		crown.scale = Vector3(1.0, 1.25, 1.0)
		tree.add_child(crown)

func _spawn_ruins() -> void:
	var ruin := Node3D.new()
	ruin.position = Vector3(0.0, 0.0, -15.0)
	add_child(ruin)
	for i in range(4):
		var pillar_mesh := BoxMesh.new()
		pillar_mesh.size = Vector3(0.8, 3.2, 0.8)
		var pillar := MeshInstance3D.new()
		pillar.mesh = pillar_mesh
		pillar.material_override = _stone_material
		pillar.position = Vector3(-3.0 + float(i) * 2.0, 1.6, 0.0)
		ruin.add_child(pillar)
	var lintel_mesh := BoxMesh.new()
	lintel_mesh.size = Vector3(7.0, 0.7, 1.0)
	var lintel := MeshInstance3D.new()
	lintel.mesh = lintel_mesh
	lintel.material_override = _stone_material
	lintel.position = Vector3(0.0, 3.25, 0.0)
	ruin.add_child(lintel)

	var altar_mesh := BoxMesh.new()
	altar_mesh.size = Vector3(2.0, 0.8, 1.5)
	var altar := MeshInstance3D.new()
	altar.mesh = altar_mesh
	altar.material_override = _stone_material
	altar.position = Vector3(0.0, 0.4, -3.0)
	ruin.add_child(altar)

func _spawn_rocks() -> void:
	for i in range(18):
		var rock_mesh := SphereMesh.new()
		var size := _rng.randf_range(0.35, 0.9)
		rock_mesh.radius = size
		rock_mesh.height = size * 1.4
		var rock := MeshInstance3D.new()
		rock.mesh = rock_mesh
		rock.material_override = _stone_material
		rock.position = Vector3(
			_rng.randf_range(-forest_radius, forest_radius),
			size * 0.35,
			_rng.randf_range(-forest_radius, forest_radius)
		)
		rock.scale = Vector3(1.2, 0.8, 1.0)
		add_child(rock)
