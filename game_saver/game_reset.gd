extends Node2D
@export var game_saver: Node

func _ready() -> void:
	game_saver.reset_save()
