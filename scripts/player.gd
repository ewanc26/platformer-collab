extends RigidBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var camera_distance := 2.5
var camera_height := 1.0

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var camera := $TwistPivot/PitchPivot/Camera3D
@onready var model := $Model

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Set initial camera position
	camera.position = Vector3(0, camera_height, camera_distance)

func _process(delta: float) -> void:
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_backwards")
	
	# Calculate the movement force based on the camera's direction
	var forward_direction = twist_pivot.basis.z.normalized()
	var force = forward_direction * input.z * 1200.0 * delta
	
	# Add sideways movement perpendicular to the camera's forward direction
	var right_direction = twist_pivot.basis.x.normalized()
	force += right_direction * input.x * 1200.0 * delta
	
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
