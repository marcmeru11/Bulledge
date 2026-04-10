extends Node

var all_skins: Array[SkinData] = []
var selected_skin: SkinData

func _ready() -> void:
	load_skins_manually()

func load_skins_manually():
	var path = "res://resources/skins/"
	
	# --- IMPORTANTE: Añade aquí los nombres exactos de tus archivos .tres ---
	var skin_files = [
		"default.tres",
		"white.tres"
	]
	
	all_skins.clear() # Limpiamos por si acaso
	
	for file_name in skin_files:
		var full_path = path + file_name
		
		# Verificamos si el archivo existe antes de cargarlo
		if ResourceLoader.exists(full_path):
			var skin = load(full_path)
			if skin is SkinData:
				all_skins.append(skin)
				print("Skin cargada correctamente: ", file_name)
		else:
			print("ERROR: No se encontró el archivo de skin en: ", full_path)

	# Si después de intentar cargar no hay nada, lanzamos un aviso serio
	if all_skins.size() == 0:
		print("ALERTA: No se cargó ninguna skin. Revisa los nombres en SkinManager.gd")

# --- FUNCIONES DE PERSISTENCIA (TALO) ---

func save_skin_to_talo(skin_name: String):
	if Talo.current_player:
		Talo.current_player.set_prop("selected_skin", skin_name)
		# Forzamos el guardado de propiedades si tu versión de Talo lo requiere
		# Talo.current_player.save_props() 
		print("Skin guardada en la nube: ", skin_name)

func load_skin_from_talo() -> SkinData:
	if Talo.current_player:
		var skin_name = Talo.current_player.get_prop("selected_skin")
		
		if skin_name:
			for s in all_skins:
				if s.skin_name == skin_name:
					selected_skin = s
					return s
	
	# Fallback: Si no hay internet o no hay skin guardada, usamos la primera de la lista
	if all_skins.size() > 0:
		selected_skin = all_skins[0]
	return selected_skin

# Función auxiliar para el sistema de desbloqueo por récord
func get_best_unlocked_skin(current_highscore: float) -> SkinData:
	if all_skins.size() == 0: return null
	
	var best_skin = all_skins[0]
	for skin in all_skins:
		if current_highscore >= skin.required_score:
			if skin.required_score > best_skin.required_score:
				best_skin = skin
	return best_skin
