extends Area3D

@export var display_name: String = "Ancient Shard"

func _enter_tree() -> void:
	add_to_group("relic_pickups")

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
