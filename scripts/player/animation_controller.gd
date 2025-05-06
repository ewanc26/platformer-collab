extends Node

# Animation controller for the player character
# Handles loading and playing animations from the model

# Node references
var model: Node3D
var animation_player: AnimationPlayer

# Animation states
enum AnimationState {
	IDLE,
	WALK,
	RUN,
	JUMP_UP,
	JUMP_DOWN
}

# Current animation state
var current_state: AnimationState = AnimationState.IDLE

# Animation names from the GLB file
const ANIM_WALK: String = "walk"
const ANIM_RUN: String = "run"
const ANIM_UP: String = "up"
const ANIM_DOWN: String = "down"

# Speed thresholds for determining animation state
const WALK_THRESHOLD: float = 0.1
const RUN_THRESHOLD: float = 5.0

func _init(player_model: Node3D) -> void:
	model = player_model

# Called when the node enters the scene tree
func _ready() -> void:
	# The model might not be fully loaded yet, so we need to wait
	if !model.is_inside_tree():
		await model.ready
	
	# Debug the model structure to find animations
	print("Model structure:")
	print_node_tree(model)
	
	# Find the animation player in the model
	animation_player = find_animation_player(model)
	
	if animation_player:
		print("Animation player found: ", animation_player.name)
		print("Available animations: ", animation_player.get_animation_list())
	else:
		push_error("No AnimationPlayer found in the model!")

# Print the node tree for debugging
func print_node_tree(node: Node, indent: String = "") -> void:
	print(indent, node.name, " (", node.get_class(), ")")
	
	for child in node.get_children():
		print_node_tree(child, indent + "  ")


# Recursively search for the AnimationPlayer node
func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	
	for child in node.get_children():
		var found = find_animation_player(child)
		if found:
			return found
	
	return null

# Update the animation based on player state
func update_animation(velocity: Vector3, is_grounded: bool, is_jumping: bool) -> void:
	if !animation_player:
		return
	
	# Calculate horizontal speed (ignoring vertical movement)
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
	# Determine the appropriate animation state
	var new_state = current_state
	
	if !is_grounded:
		if velocity.y > 0:
			new_state = AnimationState.JUMP_UP
		else:
			new_state = AnimationState.JUMP_DOWN
	elif horizontal_speed > RUN_THRESHOLD:
		new_state = AnimationState.RUN
	elif horizontal_speed > WALK_THRESHOLD:
		new_state = AnimationState.WALK
	else:
		new_state = AnimationState.IDLE
	
	# Only change animation if state has changed
	if new_state != current_state:
		current_state = new_state
		play_animation_for_state(current_state)

# Play the appropriate animation for the given state
func play_animation_for_state(state: AnimationState) -> void:
	if !animation_player:
		return
	
	# Get available animations
	var available_animations = animation_player.get_animation_list()
	
	# Animation to play
	var anim_to_play = ""
	# Whether the animation should loop
	var should_loop = false
	
	match state:
		AnimationState.WALK:
			anim_to_play = ANIM_WALK if available_animations.has(ANIM_WALK) else ""
			should_loop = true  # Walk animation should loop
		AnimationState.RUN:
			anim_to_play = ANIM_RUN if available_animations.has(ANIM_RUN) else ANIM_WALK
			should_loop = true  # Run animation should loop
		AnimationState.JUMP_UP:
			anim_to_play = ANIM_UP if available_animations.has(ANIM_UP) else ""
			should_loop = false  # Jump up is a one-time animation
		AnimationState.JUMP_DOWN:
			anim_to_play = ANIM_DOWN if available_animations.has(ANIM_DOWN) else ""
			should_loop = false  # Landing is a one-time animation
		AnimationState.IDLE:
			# For idle, we'll just stop at the current position or play walk at slow speed
			if available_animations.has(ANIM_WALK):
				animation_player.play(ANIM_WALK)
				animation_player.speed_scale = 0.3
				
				# Set the idle animation to loop
				var idle_anim = animation_player.get_animation(ANIM_WALK)
				if idle_anim:
					idle_anim.loop_mode = Animation.LOOP_LINEAR
				return
	
	# Only play if we have a valid animation
	if anim_to_play != "":
		animation_player.play(anim_to_play)
		animation_player.speed_scale = 1.0
		
		# Set looping based on animation type
		var anim = animation_player.get_animation(anim_to_play)
		if anim:
			anim.loop_mode = Animation.LOOP_LINEAR if should_loop else Animation.LOOP_NONE
		
		print("Playing animation: ", anim_to_play, " (Looping: ", should_loop, ")")
	else:
		# If no animation is available for this state, use a fallback or do nothing
		print("No animation available for state: ", state)
