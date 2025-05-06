extends Node

# Process movement input
func get_movement_input() -> Vector3:
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backwards")
	
	return input

# Handle UI input like ESC key
func handle_ui_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)