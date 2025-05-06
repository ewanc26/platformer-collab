extends RigidBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var camera_distance := 2.5
var camera_height := 1.0

# Camera state variables
var is_camera_coupled := false
var last_movement_time := 0.0
var camera_decoupling_delay := 0.5  # Time in seconds before decoupling after stopping

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var camera := $TwistPivot/PitchPivot/Camera3D
@onready var model := $Model
@onready var grounded := $Grounded

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Set initial camera position
	camera.position = Vector3(0, camera_height, camera_distance)
	# Start with decoupled camera
	is_camera_coupled = false

func _process(delta: float) -> void:
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backwards")
	
	# Handle camera coupling based on movement
	if input.length() > 0.1:
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
	
	# Calculate the movement force based on the camera's direction
	var forward_direction = twist_pivot.basis.z.normalized()
	var force = forward_direction * input.z * 1200.0 * delta
	
	# Add sideways movement perpendicular to the camera's forward direction
	var right_direction = twist_pivot.basis.x.normalized()
	force += right_direction * input.x * 1200.0 * delta
	
	if Input.is_action_just_pressed("jump") && grounded.is_colliding():
		force += Vector3.UP * 500
	
	apply_central_force(force)
	
	# Rotate the model based on camera direction when moving
	if input.length() > 0.1:
		# Make the model face away from the camera
		var target_direction = twist_pivot.basis.z.normalized()
		model.look_at(model.global_position + target_direction, Vector3.UP)
		# Adjust for the model's initial rotation (-90 degrees on Y axis from the scene file)
		model.rotation.y += PI/2
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Update camera rotation based on mouse input
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
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity
