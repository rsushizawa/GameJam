extends Area2D

@export var speed: float = 500
@export var direction = Vector2.UP

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func setDirection(Direction: Vector2) -> void:
	direction = Direction

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(1)
			queue_free()
