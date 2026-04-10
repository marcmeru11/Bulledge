extends Node

var all_skins: Array[SkinData] = []
var selected_skin: SkinData
var player_highscore: float = 0.0

func _ready() -> void:
	load_skins_manually()
	fetch_highscore_from_talo()

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

func fetch_highscore_from_talo():
	if Talo.current_player:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.player_id = Talo.current_player.id
		
		var res = await Talo.leaderboards.get_entries("main", options)
		
		if res.entries.size() > 0:
			player_highscore = res.entries[0].score
			print("Record de Talo recuperado: ", player_highscore)
		else:
			player_highscore = 0.0

func is_skin_unlocked(skin: SkinData) -> bool:
	if skin.required_score <= 0:
		return true
	
	return player_highscore >= skin.required_score

func save_skin_to_talo(skin_to_save: SkinData):
	if Talo.current_player:
		Talo.current_player.set_prop("selected_skin", skin_to_save.skin_name)
		selected_skin = skin_to_save
