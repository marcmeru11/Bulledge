extends Control

func _ready() -> void:
	visible = false
	$CanvasLayer.visible = false
	$CanvasLayer/VBoxContainer/Play.disabled = true
	$CanvasLayer/VBoxContainer/Back.disabled = true

func _on_play_pressed() -> void:
	restart()

func enable(): 
	visible = true
	$CanvasLayer.visible = true
	$CanvasLayer/VBoxContainer/Play.disabled = false
	$CanvasLayer/VBoxContainer/Back.disabled = false


func set_scores(high: float, current: float):
	print(high, current)
	$CanvasLayer/VBoxContainer/CurrentScore.text = "SCORE: %.1f" % current
	var text
	if high == -1 or current > high:
		text = "NEW HIGH SCORE!"
	else:
		text = "HIGH SCORE: %.1f" % high
	$CanvasLayer/VBoxContainer/HighScore.text = text
	


func _on_back_pressed() -> void:
	back()
	

func _physics_process(_delta: float) -> void:
	if visible:
		if Input.is_action_just_pressed("reset"):
			restart()
		if Input.is_action_just_pressed("esc"):
			back()
		
		
func back() -> void:
	get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")


func restart() -> void:
	get_tree().change_scene_to_file("res://Level/level.tscn")
