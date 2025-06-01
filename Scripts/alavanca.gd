extends Area2D

@export var fada: Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Entered Lever")
		if fada.has_method("sleep"):
			fada.sleep()
			print("Fada put to sleep")
