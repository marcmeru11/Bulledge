extends Node

@export var gameOverMenu: Control
@export var generator_controller: Node
@export var time_to_stage_change: float = 15
@export var game_interface: Node
# Ya no necesitamos el game_saver local si todo va a la nube

@export var leaderboard_name: String = "Month" 

var time: float = 0.0
var high_score: float = 0.0

func _ready() -> void:
	start_timer()
	game_interface.update_secs(time)
	$timeTimer.start(0.1)
	
	# Cargamos el high score de la nube al empezar
	_load_high_score_from_talo()

func _load_high_score_from_talo() -> void:
	if Talo.current_player:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.player_id = Talo.current_player.id
		
		var res = await Talo.leaderboards.get_entries(leaderboard_name, options)
		if res.entries.size() > 0:
			# Dividimos por 10.0 para pasar de 69 a 6.9
			high_score = float(res.entries[0].score) / 10.0
			print("High score real recuperado: ", high_score)

func _on_player_death() -> void:
	$StageTimer.stop()
	$timeTimer.stop()
	
	# 1. Mostramos el menú inmediatamente con el high_score que ya teníamos cargado
	gameOverMenu.set_scores(high_score, time)
	gameOverMenu.enable()
	
	# 2. Intentamos guardar en la nube
	save_score_to_talo()

func save_score_to_talo() -> void:
	if !Talo.current_player:
		return

	var score_to_send: int = int(time * 10)
	var res = await Talo.leaderboards.add_entry(leaderboard_name, score_to_send)

	if res:
		# Con "Unique entries" activo en el dashboard, 
		# res.updated solo será true si realmente superaste tu récord anterior
		if res.updated:
			high_score = float(res.entry.score) / 10.0
			# Actualizamos el menú con el nuevo récord
			gameOverMenu.set_scores(high_score, time)
			print("Récord actualizado en caliente")
		else:
			print("Puntuación enviada, pero no superó el récord.")
# --- FUNCIONES DE TIEMPO ---

func start_timer():
	$StageTimer.start(time_to_stage_change)

func _on_timer_timeout() -> void:
	start_timer()
	generator_controller.generators_limits += 1

func _on_time_timer_timeout() -> void:
	$timeTimer.start(0.1)
	time += 0.1
	game_interface.update_secs(time)
