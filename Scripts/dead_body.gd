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
	DeadBodyManager.cleanup_invalid_bodies()
	about_to_despawn.emit(self) # Emit the signal *before* queue_free
	queue_free() # Remove the dead body from the scene
