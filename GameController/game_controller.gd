extends Node

@export var gameOverMenu: Control
@export var generator_controller: Node
@export var time_to_stage_change: float = 15
@export var game_interface: Node
@export var game_saver: Node

var time: float = 0.0

func _ready() -> void:
	start_timer()
	game_interface.update_secs(time)
	$timeTimer.start(0.1)

func _on_player_death() -> void:
	$StageTimer.stop()
	$timeTimer.stop()
	gameOverMenu.set_scores(get_high_score(), time)
	gameOverMenu.enable()
	save_score()
	


func start_timer():
	$StageTimer.start(time_to_stage_change)

func _on_timer_timeout() -> void:
	start_timer()
	generator_controller.generators_limits += 1


func _on_time_timer_timeout() -> void:
	$timeTimer.start(0.1)
	time+=0.1
	game_interface.update_secs(time)

func save_score() -> void:
	if time > get_high_score():
		game_saver.save_high_score(time)
		
func get_high_score() -> float:
	return game_saver.load_high_score()
	
