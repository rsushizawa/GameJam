extends Node

@export var dead_body_scene: PackedScene = preload("res://Scenes/dead_body.tscn") # Assign your DeadBody.tscn in the Inspector for this Autoload
@export var max_dead_bodies: int = 5    # Set your desired maximum

var active_bodies: Array[Node2D] = [] # To store references to active dead bodies

# Call this function to spawn a new dead body
func request_spawn_dead_body(body: Node2D,colisionshape: Node2D, spawn_position: Vector2, initial_velocity: Vector2):
	if not dead_body_scene:
		print("DeadBodyManager: dead_body_scene is not set!")
		return

	# If we've reached the max, remove the oldest one
	if active_bodies.size() >= max_dead_bodies:
		var oldest_body: Node2D = active_bodies.pop_front() # Get and remove the first (oldest) body
		if is_instance_valid(oldest_body):
			print("DeadBodyManager: Despawning oldest dead body - ", oldest_body.name)
			oldest_body.queue_free()
		else:
			print("DeadBodyManager: Oldest body was already invalid, removed from list.")

	# Instantiate and initialize the new dead body
	var new_body_instance = dead_body_scene.instantiate()

	if new_body_instance:
		new_body_instance.global_position.y = spawn_position.y - colisionshape.shape.size.y * body.scale.y
		new_body_instance.global_position.x = spawn_position.x
		new_body_instance.linear_velocity = initial_velocity
		# Add to the current scene
		get_tree().current_scene.add_child(new_body_instance)
		active_bodies.append(new_body_instance) # Add to our tracking list (at the end)

	elif new_body_instance: # If it's not a RigidBody2D but still valid
		new_body_instance.global_position = spawn_position
		get_tree().current_scene.add_child(new_body_instance)
		active_bodies.append(new_body_instance)
		print("DeadBodyManager: Spawned dead body is not a RigidBody2D. Limited functionality.")
	else:
		print("DeadBodyManager: Failed to instance dead_body_scene.")

# --- _on_body_settle_timer_timeout FUNCTION REMOVED ---

# Optional: Clean up list if bodies are removed by other means
func cleanup_invalid_bodies():
	var i = active_bodies.size() - 1
	while i >= 0:
		if not is_instance_valid(active_bodies[i]):
			active_bodies.remove_at(i)
		i -= 1
