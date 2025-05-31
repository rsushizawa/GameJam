# Player.gd
extends CharacterBody2D

@export var speed = 200.0
@export var jump_velocity = -400.0
@export var gravity = 1200.0

# Preload the DeadBody scene so we can instance it
@export var dead_body_scene: PackedScene # Drag DeadBody.tscn here in the Inspector

# You might want to get the spawn point dynamically or have a default
var spawn_position = Vector2.ZERO # Default spawn, will be updated

func _ready():
	# Attempt to find the SpawnPoint in the current level when the player is ready
	var spawn_point_node = get_tree().current_scene.find_child("SpawnPoint", true, false)
	if spawn_point_node:
		spawn_position = spawn_point_node.global_position
	else:
		print("WARNING: SpawnPoint node not found in the scene. Player will respawn at (0,0) or its initial position.")
		spawn_position = global_position # Fallback to initial position if no SpawnPoint

	# Add player to a group if you haven't already (useful for spike detection etc.)
	add_to_group("player")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * speed
		$Sprite2D.flip_h = direction < 0 # Assuming Sprite2D is your player's sprite
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func take_damage(amount):
	print("Player took damage: ", amount)
	# Here you would implement logic for losing health.
	# For now, any damage causes death.
	die() 

func die():
	print("Player died!")

	if dead_body_scene:
		# 1. Create an instance of the DeadBody
		var body_instance = dead_body_scene.instantiate()
		var player_position = global_position
		# 2. Set its position and orientation
		print("Player global position at death: ",player_position)
		body_instance.global_position.y = player_position.y - $CollisionShape2D.shape.size.y * scale.y
		body_instance.global_position.x = player_position.x
		if body_instance.has_node("Sprite2D"): # Check if DeadBody has a Sprite2D
			body_instance.get_node("Sprite2D").flip_h = $Sprite2D.flip_h # Match player's flip
		
		# 3. Add the dead body to the current scene (the level)
		#    get_parent() assumes player is a direct child of the level.
		#    If not, get_tree().current_scene.add_child(body_instance) is safer.
		get_tree().current_scene.add_child(body_instance) 
		
		
		print("Player global position at death: ",global_position)
		print("Dead body spawned at: ", body_instance.global_position)
	else:
		print("WARNING: DeadBody scene not set in Player script.")

	# 4. Respawn the player
	global_position = spawn_position
	velocity = Vector2.ZERO # Reset velocity
	# You might need to reset other states here (e.g., health, animation state)
	
	# Optional: If you have a specific "idle" or "respawn" animation
	# if $AnimatedSprite2D.has_animation("idle"):
	#    $AnimatedSprite2D.play("idle")

	print("Player respawned at: ", global_position)

	# Instead of reloading the whole scene:
	# get_tree().reload_current_scene() # This would remove the dead body too
