# Player.gd
extends CharacterBody2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

@export var speed = 200.0
@export var jump_velocity = -400.0
@export var gravity = 1200.0
# Preload the DeadBody scene so we can instance it
@export var dead_body_scene: PackedScene # Drag DeadBody.tscn here in the Inspector
@export var dead_body_freeze_scene: PackedScene # Drag DeadBody.tscn here in the Inspector
# You might want to get the spawn point dynamically or have a default
var spawn_position = Vector2.ZERO
var number_items = 0
@onready var dead_body_freeze_nodes = get_tree().get_nodes_in_group("DeadBodyFreeze")

func _ready():
	# Attempt to find the SpawnPoint in the current level when the player is ready
	var spawn_point_node = get_tree().current_scene.find_child("SpawnPoint", true, false)
	if spawn_point_node:
		spawn_position = spawn_point_node.global_position
	else:
		print("WARNING: SpawnPoint node not found in the scene. Player will respawn at (0,0) or its initial position.")
		spawn_position = global_position # Fallback to initial position if no SpawnPoint

	# Add player to a group if you haven't already (useful for spike detection etc.)
	add_to_group("Player")


func _physics_process(delta):
	dead_body_freeze_nodes = get_tree().get_nodes_in_group("DeadBodyFreeze")
	
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

	if Input.is_key_pressed(KEY_Q):
		if dead_body_freeze_nodes.is_empty():
			DeadBodyManager.state = DeadBodyManager.Body_States.FREEZE
		else:
			DeadBodyManager.state = DeadBodyManager.Body_States.NORMAL
	elif not dead_body_freeze_nodes.is_empty():
		DeadBodyManager.state = DeadBodyManager.Body_States.NORMAL
	if Input.is_key_pressed(KEY_E):
		DeadBodyManager.state = DeadBodyManager.Body_States.NORMAL

	move_and_slide()

func pickUpItem():
	number_items +=1
	print(number_items)

func take_damage(amount):
	print("Player took damage: ", amount)
	die() 

func die() -> void:
	print("Player died!")
	death_sound.play()
	var player_death_position = global_position
	var player_current_velocity = Vector2.ZERO
	if is_instance_valid(collision_shape_2d):
		collision_shape_2d.call_deferred("set_disabled", true)
	await get_tree().physics_frame
	if dead_body_scene:
		DeadBodyManager.call_deferred("request_spawn_dead_body",
			self,                   # _spawner_node (Player instance)
			spawn_position,        # _spawner_collision_shape (Player's collision shape)
			player_death_position,  # Position where the dead body should appear
			player_current_velocity # Initial velocity for the dead body
		)

	if is_instance_valid(collision_shape_2d):
		collision_shape_2d.call_deferred("set_disabled", false)
		# If you were in an async function, you could also do:
		# await get_tree().physics_frame
		# collision_shape.disabled = false
	
	print("Player respawned at: ", global_position)
