extends CharacterBody2D

@export var speed = 200.0
@export var jump_velocity = -400.0
@export var gravity = 1200.0 # Project Settings > Physics > 2d > Default Gravity can also be used

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): # "ui_accept" is usually Spacebar
		velocity.y = jump_velocity

	# Get input direction for horizontal movement.
	var direction = Input.get_axis("ui_left", "ui_right") # "ui_left" is A/Left Arrow, "ui_right" is D/Right Arrow

	# Apply movement
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed) # Apply friction/slowdown

	move_and_slide()

	# Optional: Flip sprite based on direction
	if direction > 0:
		$Sprite2D.flip_h = false # Assuming Sprite2D is the name of your sprite node
	elif direction < 0:
		$Sprite2D.flip_h = true
		
