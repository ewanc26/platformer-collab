extends Node

# Node references
var grounded: RayCast3D
var model: Node3D
var parent: RigidBody3D

# Movement parameters
var jump_force := 500.0
var movement_force := 1200.0

# State tracking
var is_jumping := false
var jump_cooldown := 0.0

func _init(player_parent: RigidBody3D, player_model: Node3D, player_grounded: RayCast3D) -> void:
	parent = player_parent
	model = player_model
	grounded = player_grounded

# Apply movement forces based on input and camera direction
func apply_movement(input: Vector3, forward_dir: Vector3, right_dir: Vector3, delta: float) -> void:
	# Calculate the movement force based on the camera's direction
	var force = forward_dir * input.z * movement_force * delta
	
	# Add sideways movement perpendicular to the camera's forward direction
	force += right_dir * input.x * movement_force * delta
	
	# Apply the calculated force
	parent.apply_central_force(force)

# Handle jumping
func handle_jump() -> void:
	# Decrease jump cooldown if active
	if jump_cooldown > 0:
		jump_cooldown -= get_process_delta_time()
	
	# Check if player is on ground
	var on_ground = grounded.is_colliding()
	
	# Reset jumping state when landing
	if on_ground && is_jumping && jump_cooldown <= 0:
		is_jumping = false
	
	# Handle jump input
	if Input.is_action_just_pressed("jump") && on_ground:
		parent.apply_central_force(Vector3.UP * jump_force)
		is_jumping = true
		jump_cooldown = 0.2  # Short cooldown to prevent immediate state change

# Rotate the model based on movement direction
func rotate_model(input_length: float, forward_dir: Vector3) -> void:
	if input_length > 0.1:
		# Make the model face away from the camera
		var target_direction = forward_dir
		model.look_at(model.global_position + target_direction, Vector3.UP)
		# Adjust for the model's initial rotation (-90 degrees on Y axis from the scene file)
		model.rotation.y += PI/2