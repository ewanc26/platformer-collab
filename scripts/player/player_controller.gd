extends RigidBody3D

# Load the modular components
var camera_controller
var movement_controller
var input_controller

# Node references
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var camera := $TwistPivot/PitchPivot/Camera3D
@onready var model := $Model
@onready var grounded := $Grounded

func _ready() -> void:
	# Initialize input controller
	input_controller = load("res://scripts/player/input_controller.gd").new()
	add_child(input_controller)
	
	# Initialize camera controller with required node references
	camera_controller = load("res://scripts/player/camera_controller.gd").new(twist_pivot, pitch_pivot, camera, model)
	add_child(camera_controller)
	
	# Initialize movement controller with required node references
	movement_controller = load("res://scripts/player/movement_controller.gd").new(self, model, grounded)
	add_child(movement_controller)
	
	# Set initial mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	# Get movement input
	var input = input_controller.get_movement_input()
	
	# Handle camera coupling based on movement
	camera_controller.handle_camera_coupling(input.length())
	
	# Get camera directions for movement
	var forward_dir = camera_controller.get_forward_direction()
	var right_dir = camera_controller.get_right_direction()
	
	# Apply movement forces
	movement_controller.apply_movement(input, forward_dir, right_dir, delta)
	
	# Handle jumping
	movement_controller.handle_jump()
	
	# Rotate model based on movement
	movement_controller.rotate_model(input.length(), forward_dir)
	
	# Handle UI input (like ESC key)
	input_controller.handle_ui_input()
	
	# Update camera rotation based on mouse input
	camera_controller.update_camera_rotation()

func _unhandled_input(event: InputEvent) -> void:
	# Pass mouse input to camera controller
	camera_controller.handle_mouse_input(event)
