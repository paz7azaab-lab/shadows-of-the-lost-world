extends CharacterBody3D

@export var move_speed: float = 5.0
@export var acceleration: float = 16.0
@export var gravity: float = 18.0

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.limit_length(1.0)

	var forward := -global_basis.z
	var right := global_basis.x
	var move_direction := (right * input_vector.x - forward * input_vector.y).normalized()
	velocity.x = move_toward(velocity.x, move_direction.x * move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, move_direction.z * move_speed, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()
