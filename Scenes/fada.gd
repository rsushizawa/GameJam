extends StaticBody2D

const PROJETIL = preload("res://Scenes/projetil.tscn")
@onready var timer: Timer = $Timer
@onready var player_nodes = get_tree().get_nodes_in_group("player")

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	var player = player_nodes[0]
	var direction = player.global_position - global_position
	
