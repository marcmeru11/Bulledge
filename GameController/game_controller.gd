extends Node



# --- REFERENCIAS A NODOS ---
@export var gameOverMenu: Control
@export var generator_controller: Node
@export var game_interface: Node
@export var leaderboard_name: String = "Month"

# --- VARIABLES DE ESTADO ---
var time: float = 0.0
var high_score: float = 0.0
var time_to_stage_change: float = 15.0

func _ready() -> void:
	# 1. Inicializar timers e interfaz
	game_interface.update_secs(time)
	$timeTimer.start(0.1)
	start_timer()
	
	# 2. Cargar datos de Talo y aplicar la Skin guardada
	await _initialize_game_data()

func _initialize_game_data() -> void:
	if Talo.current_player:
		# Recuperamos el récord para saber qué puede desbloquear
		await _load_high_score_from_talo()
		
		# Recuperamos la skin que el usuario dejó seleccionada en la nube
		var saved_skin = SkinManager.load_skin_from_talo()
		_apply_skin_to_player(saved_skin)
	else:
		# Si no hay internet/sesión, ponemos la skin por defecto
		var default_skin = SkinManager.load_skin_from_talo()
		_apply_skin_to_player(default_skin)

func _load_high_score_from_talo() -> void:
	var options := Talo.leaderboards.GetEntriesOptions.new()
	options.player_id = Talo.current_player.id
	
	var res = await Talo.leaderboards.get_entries(leaderboard_name, options)
	if res.entries.size() > 0:
		# Convertimos de entero (Talo) a float (Juego) -> 69 a 6.9
		high_score = float(res.entries[0].score) / 10.0
		print("High score recuperado de la nube: ", high_score)

func _apply_skin_to_player(skin: SkinData) -> void:
	# Buscamos al jugador en el grupo "Player"
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("apply_skin"):
		player.apply_skin(skin)
		print("Skin aplicada visualmente: ", skin.skin_name)

func _on_player_death() -> void:
	$StageTimer.stop()
	$timeTimer.stop()
	
	# Mostramos menú con el récord actual y el tiempo conseguido
	gameOverMenu.set_scores(high_score, time)
	gameOverMenu.enable()
	
	# Guardamos la puntuación en Talo
	save_score_to_talo()

func save_score_to_talo() -> void:
	if !Talo.current_player:
		return

	# Pasamos de 6.9s a 69 para la leaderboard
	var score_to_send: int = int(time * 10)
	var res = await Talo.leaderboards.add_entry(leaderboard_name, score_to_send)

	if res and res.updated:
		high_score = float(res.entry.score) / 10.0
		gameOverMenu.set_scores(high_score, time)
		print("¡Nuevo récord guardado en Talo!")

# --- FUNCIONES DE TIEMPO Y DIFICULTAD ---

func start_timer():
	$StageTimer.start(time_to_stage_change)

func _on_timer_timeout() -> void:
	start_timer()
	if generator_controller:
		generator_controller.generators_limits += 1

func _on_time_timer_timeout() -> void:
	$timeTimer.start(0.1)
	time += 0.1
	game_interface.update_secs(time)
