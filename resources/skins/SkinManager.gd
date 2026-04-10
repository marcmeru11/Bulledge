extends Node

var all_skins: Array[SkinData] = []
var selected_skin: SkinData
var player_highscore: float = 0.0 

func _ready() -> void:
	load_skins_manually()

func load_skins_manually():
	var path = "res://resources/skins/"
	var skin_files = ["default.tres", "white.tres", "spaceship.tres"]
	
	all_skins.clear()
	for file_name in skin_files:
		var full_path = path + file_name
		if ResourceLoader.exists(full_path):
			var skin = load(full_path)
			if skin is SkinData:
				all_skins.append(skin)
	print("[SkinManager] Skins cargadas en memoria: ", all_skins.size())

func fetch_highscore_from_talo() -> float:
	if Talo.current_player:
		print("[SkinManager] Consultando Talo para el jugador ID: ", Talo.current_player.id)
		
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.player_id = Talo.current_player.id
		
		# CAMBIA "main" si tu tabla tiene otro nombre interno
		var res = await Talo.leaderboards.get_entries("main", options)
		
		if res.entries.size() > 0:
			player_highscore = res.entries[0].score
			print("[SkinManager] ¡ÉXITO! Score recuperado de Talo: ", player_highscore)
		else:
			print("[SkinManager] El jugador no tiene entradas en la tabla 'main'. Score = 0")
			player_highscore = 0.0
	else:
		print("[SkinManager] ERROR: No hay jugador identificado en Talo.")
		player_highscore = 0.0
	
	return player_highscore

func is_skin_unlocked(skin: SkinData) -> bool:
	if skin.required_score <= 0:
		return true
	
	var unlocked = player_highscore >= skin.required_score
	print("[SkinManager] Comprobando skin '", skin.skin_name, "': Record(", player_highscore, ") >= Req(", skin.required_score, ") -> ", unlocked)
	return unlocked
