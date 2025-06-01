# DeadBody.gd
extends RigidBody2D # Or whatever your DeadBody's root node type is

# Signal to notify the DeadBodyManager (or any other interested node)
# that this body is about to despawn itself.
signal about_to_despawn(body_instance)

var current_scene_name := ""

func _ready():
	current_scene_name = get_tree().current_scene.name
	print("Cena atual:", current_scene_name)
	# Get the Timer node. Make sure the path is correct if you named it differently
	# or if it's not a direct child.
	var lifespan_timer = get_node_or_null("LifespanTimer") 
	if lifespan_timer:
		lifespan_timer.timeout.connect(_on_LifespanTimer_timeout)
func _on_LifespanTimer_timeout():
	about_to_despawn.emit(self) # Emit the signal *before* queue_free
	queue_free() # Remove the dead body from the scene


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var impulso_por_fase = {
			"level1": 500,
			"level2": 350,
			"level3": 550,
			"level4": 1000
		}

		var impulso = impulso_por_fase.get(Lvlmanager.lvl, 500)  # valor padrão: 500

		body.velocity.y -= impulso
		queue_free()
