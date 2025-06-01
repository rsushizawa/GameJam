extends AnimatableBody2D

const PROJETIL = preload("res://Scenes/projetil.tscn")
@onready var timer: Timer = $Area2D/golemTimer
@onready var player_nodes = get_tree().get_nodes_in_group("Player")
@onready var fire: AudioStreamPlayer2D = $Fire
@onready var fire_timer: Timer = $Area2D/fireTimer

enum golem_state {NORMAL,SLEEP}
var state: golem_state = golem_state.NORMAL

func _ready() -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if timer.is_stopped():
			print("Player Entered Fada Area 2D firing")
			timer.start()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if not timer.is_stopped():
			print("Player Exited Fada Area 2D stoped firing")
			timer.stop()
			fire_timer.stop()

func sleep():
	print("Inside Sleep")
	if state == golem_state.NORMAL:
		print("Inside Sleep SLEEP")
		state = golem_state.SLEEP
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		print("Inside Sleep NORMAL")
		state = golem_state.NORMAL
		process_mode = Node.PROCESS_MODE_ALWAYS


func _on_golem_timer_timeout() -> void:
	fire.play()
	fire_timer.start()


func _on_fire_timer_timeout() -> void:
	var player = player_nodes[0]
	var direction = player.global_position - global_position
	var new_projectile = PROJETIL.instantiate()
	new_projectile.global_position = global_position
	new_projectile.setDirection(direction.normalized())
	get_tree().current_scene.add_child(new_projectile)
	timer.start()
