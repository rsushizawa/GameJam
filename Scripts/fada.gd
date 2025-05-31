extends AnimatableBody2D

const PROJETIL = preload("res://Scenes/projetil.tscn")
@onready var timer: Timer = %FadaTimer
@onready var player_nodes = get_tree().get_nodes_in_group("player")

@export var point_a_path: NodePath
@export var point_b_path: NodePath
@export var travel_duration: float = 2.0 # Time in seconds to travel from one point to the other

@onready var point_a: Marker2D = get_node_or_null(point_a_path)
@onready var point_b: Marker2D = get_node_or_null(point_b_path)

var current_target_is_b: bool = true
func _ready() -> void:
	if not point_a or not point_b:
		print("Platform markers not set correctly!")
		set_physics_process(false) # Disable movement if markers are missing
		return

	# Start at Point A
	global_position = point_a.global_position
	move_to_target()

func _on_timer_timeout() -> void:
	var player = player_nodes[0]
	var direction = player.global_position - global_position
	var new_projectile = PROJETIL.instantiate()
	new_projectile.global_position = global_position
	new_projectile.setDirection(direction.normalized())
	get_tree().current_scene.add_child(new_projectile)
	timer.start()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if timer.is_stopped():
			print("Player Entered Fada Area 2D firing")
			timer.start()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not timer.is_stopped():
			print("Player Exited Fada Area 2D stoped firing")
			timer.stop()


func move_to_target():
	var target_position: Vector2
	if current_target_is_b:
		target_position = point_b.global_position
	else:
		target_position = point_a.global_position

	# Create a tween to handle the movement
	var tween = create_tween()
	# Animate the 'global_position' property of this node
	tween.tween_property(self, "global_position", target_position, travel_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# When the tween finishes, call the _on_tween_completed method
	tween.finished.connect(_on_tween_completed)


func _on_tween_completed():
	# Switch target
	current_target_is_b = not current_target_is_b
	# Move to the new target
	move_to_target()
