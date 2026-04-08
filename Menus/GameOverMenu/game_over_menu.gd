extends Control


func _ready() -> void:
	visible = false
	$CanvasLayer.visible = false
	$CanvasLayer/VBoxContainer/Play.disabled = true
	$CanvasLayer/VBoxContainer/Quit.disabled = true

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/level.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

func enable(): 
	visible = true
	$CanvasLayer.visible = true
	$CanvasLayer/VBoxContainer/Play.disabled = false
	$CanvasLayer/VBoxContainer/Quit.disabled = false

func set_scores(high: float, current: float):
	print(high, current)
	$CanvasLayer/VBoxContainer/CurrentScore.text = "SCORE: %.1f" % current
	var text
	if high == -1 or current > high:
		text = "NEW HIGH SCORE!"
	else:
		text = "HIGH SCORE: %.1f" % high
	$CanvasLayer/VBoxContainer/HighScore.text = text
	
