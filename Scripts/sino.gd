extends Area2D
@export var fada_node: Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if fada_node:
				fada_node.set_state(fada_node.FadaState.ACTIVATED)
