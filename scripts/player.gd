extends RigidBody3D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backwards")
	
	apply_central_force(input * 1200.0 * delta) 
