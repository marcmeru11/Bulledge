extends Node

var all_skins: Array[SkinData] = []
var selected_skin: SkinData

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
	
	print("Skins cargadas en Manager: ", all_skins.size())

# Función para guardar
func save_skin_to_talo(skin_to_save: SkinData):
	if Talo.current_player:
		Talo.current_player.set_prop("selected_skin", skin_to_save.skin_name)
		selected_skin = skin_to_save

# Función para cargar al inicio
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

# Función de desbloqueo (ahora más simple y robusta)
func is_skin_unlocked(skin: SkinData) -> bool:
	if skin.required_score <= 0:
		return true
		
	if Talo.current_player:
		var prop_value = Talo.current_player.get_prop("highscore")
		if prop_value != null:
			return float(prop_value) >= skin.required_score
			
	return false
