extends AnimatableBody2D

# These were in the original code, kept for consistency with your request,
# but note they are not used in the movement logic below.
const PROJETIL = preload("res://Scenes/projetil.tscn") # Unused in this movement logic
@onready var player_nodes = get_tree().get_nodes_in_group("Player") # Unused in this movement logic

@export var point_a_path: NodePath
@export var point_b_path: NodePath
@export var point_c_path: NodePath # Path for ACTIVATED state
@export var point_d_path: NodePath # Path for ACTIVATED state

@export var travel_duration: float = 2.0 # Time in seconds to travel

@onready var point_a: Marker2D = get_node_or_null(point_a_path) as Marker2D
@onready var point_b: Marker2D = get_node_or_null(point_b_path) as Marker2D
@onready var point_C: Marker2D = get_node_or_null(point_c_path) as Marker2D # Note: original script used point_C
@onready var point_D: Marker2D = get_node_or_null(point_d_path) as Marker2D # Note: original script used point_D

enum FadaState { NORMAL, ACTIVATED } # Renamed enum for convention
var current_fada_state: FadaState = FadaState.NORMAL # Public variable to change fada's state

var _is_moving_towards_second_point: bool = true # Internal: true if moving A->B or C->D, false if B->A or D->C

func _ready() -> void:
	# Initial validation of points based on initial state
	var initial_start_marker: Marker2D
	var initial_end_marker: Marker2D
	var start_position_set = false

	if current_fada_state == FadaState.ACTIVATED:
		var point_C: Marker2D = get_node_or_null(point_c_path) as Marker2D # Note: original script used point_C
		var point_D: Marker2D = get_node_or_null(point_d_path) as Marker2D
		if point_C and point_D:
			initial_start_marker = point_C
			initial_end_marker = point_D
			global_position = point_C.global_position # Start at C if ACTIVATED
			start_position_set = true
		else:
			printerr(name, ": State is ACTIVATED but point_C or point_D are not set! Trying NORMAL path or halting.")
			# Fallback to NORMAL if C or D are missing
		current_fada_state = FadaState.NORMAL # Revert state
			# Fallthrough to NORMAL state logic below
	
	if current_fada_state == FadaState.NORMAL: # Also handles fallback from ACTIVATED
		if point_a and point_b:
			initial_start_marker = point_a
			initial_end_marker = point_b
			if not start_position_set: # Only set if not already set by ACTIVATED state logic
				global_position = point_a.global_position # Start at A if NORMAL
				start_position_set = true
		else:
			printerr(name, ": Default points (A or B) for NORMAL state are not set! Movement disabled.")
			set_physics_process(false)
			return
	
	if not start_position_set: # Should not happen if logic above is correct
		printerr(name, ": Critical error - could not determine initial markers or position. Halting.")
		set_physics_process(false)
		return

	# Begin movement
	_initiate_movement_tween(initial_start_marker, initial_end_marker)


func _initiate_movement_tween(path_start_marker: Marker2D, path_end_marker: Marker2D) -> void:
	var target_node: Marker2D
	if _is_moving_towards_second_point:
		target_node = path_end_marker
	else:
		target_node = path_start_marker

	if not target_node: # Safety check
		printerr(name, ": Target marker is null! Halting movement.")
		set_physics_process(false)
		return

	var target_position: Vector2 = target_node.global_position

	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", target_position, travel_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_tween_completed)


func _on_tween_completed() -> void:
	# Toggle direction for the next segment
	_is_moving_towards_second_point = not _is_moving_towards_second_point

	# Determine which path markers to use based on the current state
	var next_start_marker: Marker2D
	var next_end_marker: Marker2D

	if current_fada_state == FadaState.ACTIVATED:
		if point_C and point_D:
			next_start_marker = point_C
			next_end_marker = point_D
		else:
			printerr(name, ": State is ACTIVATED but point_C or point_D are missing! Reverting to NORMAL path.")
			# Fallback: Revert to NORMAL path if A and B exist
			if point_a and point_b:
				next_start_marker = point_a
				next_end_marker = point_b
				current_fada_state = FadaState.NORMAL # Explicitly change state back
			else:
				printerr(name, ": Critical - Points A & B also missing for fallback. Halting.")
				set_physics_process(false) # Stop processing
				return
	else: # current_fada_state == FadaState.NORMAL
		if point_a and point_b:
			next_start_marker = point_a
			next_end_marker = point_b
		else:
			printerr(name, ": Points A or B for NORMAL state are missing! Halting.")
			set_physics_process(false) # Stop processing
			return
	
	_initiate_movement_tween(next_start_marker, next_end_marker)

# --- Public function to change the Fada's state ---
# Call this from another script: fada_instance.set_state(fada_instance.FadaState.ACTIVATED)
func set_state(new_state: FadaState) -> void:
	if current_fada_state != new_state:
		current_fada_state = new_state
		print(name, ": State changed to ", FadaState.keys()[new_state])
		# The path will update after the current movement segment completes, via _on_tween_completed.
		# If you need an *immediate* path switch (interrupting the current tween),
		# that would require more complex logic here to stop the current tween and start a new one.
