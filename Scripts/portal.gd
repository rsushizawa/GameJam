extends Area2D

@export_file("*.tscn") var next_level_scene_path: String

func _ready():
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		go_to_next_level()
		

func go_to_next_level():
	if next_level_scene_path and not next_level_scene_path.is_empty():
		print("Loading next level: " + next_level_scene_path)
		get_tree().change_scene_to_file(next_level_scene_path)
