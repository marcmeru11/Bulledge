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
	print("[SkinManager] Skins cargadas: ", all_skins.size())

func fetch_highscore_from_talo() -> float:
	if Talo.current_player:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.player_id = Talo.current_player.id
		
		var res = await Talo.leaderboards.get_entries("Month", options)
		
		if res.entries.size() > 0:
			player_highscore = res.entries[0].score
		else:
			player_highscore = 0.0
	
	return player_highscore

func is_skin_unlocked(skin: SkinData) -> bool:
	if skin.required_score * 30 <= 0:
		return true
	return float(player_highscore) >= float(skin.required_score)

func get_active_skin() -> SkinData:
	if selected_skin != null:
		return selected_skin
	
	return load_skin_from_talo()

func load_skin_from_talo() -> SkinData:
	if Talo.current_player:
		var skin_name = Talo.current_player.get_prop("selected_skin")
		if skin_name:
			for s in all_skins:
				if s.skin_name == skin_name:
					selected_skin = s
					return s
	
	if all_skins.size() > 0:
		selected_skin = all_skins[0]
		return selected_skin
		
	return null

func save_skin_to_talo(skin_to_save: SkinData):
	if Talo.current_player:
		Talo.current_player.set_prop("selected_skin", skin_to_save.skin_name)
		selected_skin = skin_to_save
