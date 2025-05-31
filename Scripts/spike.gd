extends StaticBody2D

func _on_dmg_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.has_method("die"):
			body.die()
