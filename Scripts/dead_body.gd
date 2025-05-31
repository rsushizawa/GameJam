# DeadBody.gd
extends RigidBody2D # Or whatever your DeadBody's root node type is

# Signal to notify the DeadBodyManager (or any other interested node)
# that this body is about to despawn itself.
signal about_to_despawn(body_instance)

func _ready():
	# Get the Timer node. Make sure the path is correct if you named it differently
	# or if it's not a direct child.
	var lifespan_timer = get_node_or_null("LifespanTimer") 
	if lifespan_timer:
		lifespan_timer.timeout.connect(_on_LifespanTimer_timeout)
func _on_LifespanTimer_timeout():
	about_to_despawn.emit(self) # Emit the signal *before* queue_free
	queue_free() # Remove the dead body from the scene

# You can keep or add an initialize function if the DeadBodyManager needs
# to pass initial velocity, sprite flip, etc.
func initialize_body(initial_velocity: Vector2, sprite_flip_h: bool):
	self.linear_velocity = initial_velocity
	var sprite_node = get_node_or_null("Sprite2D") # Adjust path if needed
	if sprite_node and sprite_node is Sprite2D:
		sprite_node.flip_h = sprite_flip_h
