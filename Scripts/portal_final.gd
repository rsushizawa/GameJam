extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if body.numberOfItems == 5:
			GameManager.gameOver()
