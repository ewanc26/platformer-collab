extends Node

# Camera parameters
var camera_distance := 2.5
var camera_height := 1.0
var mouse_sensitivity := 0.001

# Camera state variables
var is_camera_coupled := false
var last_movement_time := 0.0
var camera_decoupling_delay := 0.5  # Time in seconds before decoupling after stopping

# Input variables
var twist_input := 0.0
var pitch_input := 0.0

# Node references
var twist_pivot: Node3D
var pitch_pivot: Node3D
var camera: Camera3D
var model: Node3D

func _init(player_twist_pivot: Node3D, player_pitch_pivot: Node3D, player_camera: Camera3D, player_model: Node3D) -> void:
	twist_pivot = player_twist_pivot
	pitch_pivot = player_pitch_pivot
	camera = player_camera
	model = player_model
	
	# Set initial camera position
	camera.position = Vector3(0, camera_height, camera_distance)
	# Start with decoupled camera
	is_camera_coupled = false

# Handle camera coupling based on movement
func handle_camera_coupling(input_length: float) -> void:
	if input_length > 0.1:
		# Player is moving, reset timer and ensure camera is coupled
		last_movement_time = Time.get_ticks_msec() / 1000.0
		
		if !is_camera_coupled:
			# Player started moving, couple the camera
			is_camera_coupled = true
			
			# Store current camera global transform before coupling
			var camera_global_transform = twist_pivot.global_transform
			
			# Align twist pivot with model direction
			twist_pivot.global_transform.basis = model.global_transform.basis
			
			# We need to preserve the camera's pitch while updating its yaw
			var current_pitch = pitch_pivot.rotation.x
			pitch_pivot.rotation.x = current_pitch
	else:
		# Player not moving, check if we should decouple
		var current_time = Time.get_ticks_msec() / 1000.0
		if is_camera_coupled && (current_time - last_movement_time) > camera_decoupling_delay:
			is_camera_coupled = false

# Update camera rotation based on mouse input
func update_camera_rotation() -> void:
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		deg_to_rad(-30),
		deg_to_rad(30)
	)
	
	# Reset inputs
	twist_input = 0.0
	pitch_input = 0.0

# Handle mouse input for camera control
func handle_mouse_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity

# Get camera directions for movement
func get_forward_direction() -> Vector3:
	return twist_pivot.basis.z.normalized()

func get_right_direction() -> Vector3:
	return twist_pivot.basis.x.normalized()
