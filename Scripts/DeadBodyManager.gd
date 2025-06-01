extends Node

@export var dead_body_scene: PackedScene = preload("res://Scenes/dead_body.tscn") # Assign your DeadBody.tscn in the Inspector for this Autoload
@export var dead_body_freeze_scene: PackedScene = preload("res://Scenes/dead_body_freeze.tscn")# Drag DeadBody.tscn here in the Inspector
@export var max_dead_bodies: int = 5    # Set your desired maximum

enum Body_States {NORMAL,FREEZE}
var state: Body_States = Body_States.NORMAL
# Call this function to spawn a new dead body
func request_spawn_dead_body(_body: Node2D,_colisionshape: Node2D, spawn_position: Vector2, initial_velocity: Vector2):
	var dead_body_nodes = get_tree().get_nodes_in_group("DeadBody")
	var active_bodies: Array[Node] = dead_body_nodes # To store references to active dead bodies
	if not dead_body_scene:
		print("DeadBodyManager: dead_body_scene is not set!")
		return

	# If we've reached the max, remove the oldest one
	if active_bodies.size() >= max_dead_bodies:
		var oldest_body: Node2D = active_bodies[0]# Get and remove the first (oldest) body
		if is_instance_valid(oldest_body):
			print("DeadBodyManager: Despawning oldest dead body - ", oldest_body.name)
			oldest_body.queue_free()
		else:
			print("DeadBodyManager: Oldest body was already invalid, removed from list.")

	# Instantiate and initialize the new dead body
	var new_body_instance
	if state == Body_States.FREEZE:
		new_body_instance = dead_body_freeze_scene.instantiate()
	else:
		new_body_instance = dead_body_scene.instantiate()
		new_body_instance.linear_velocity = initial_velocity

	if new_body_instance:
		new_body_instance.global_position.y = spawn_position.y
		new_body_instance.global_position.x = spawn_position.x
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
