extends Area2D

@export var golem: Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("Entered Lever")
		if golem.has_method("sleep"):
			golem.sleep()
			print("Fada put to sleep")
