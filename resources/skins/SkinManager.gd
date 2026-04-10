extends Node

var all_skins: Array[SkinData] = []
var selected_skin: SkinData

func _ready() -> void:
	load_skins_from_folder()

func load_skins_from_folder():
	var path = "res://Resources/Skins/"
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres") or file_name.ends_with(".res"):
				var skin = load(path + file_name)
				if skin is SkinData:
					all_skins.append(skin)
			file_name = dir.get_next()

# --- NUEVAS FUNCIONES DE PERSISTENCIA ---

func save_skin_to_talo(skin_name: String):
	if Talo.current_player:
		# Guardamos el nombre de la skin en la nube de Talo
		Talo.current_player.set_prop("selected_skin", skin_name)
		print("Skin guardada en Talo: ", skin_name)

func load_skin_from_talo() -> SkinData:
	if Talo.current_player:
		# Leemos la propiedad de Talo
		var skin_name = Talo.current_player.get_prop("selected_skin")
		
		if skin_name:
			# Buscamos en nuestra lista la skin que coincida con ese nombre
			for s in all_skins:
				if s.skin_name == skin_name:
					selected_skin = s
					return s
	
	# Si no hay nada guardado o no se encuentra, devolvemos la default (puntos 0)
	selected_skin = all_skins[0]
	return selected_skin
