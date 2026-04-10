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
		"white.tres",
		"spaceship.tres"
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

# Ahora solo pide la skin, el record lo busca él solo
func save_skin_to_talo(skin_to_save: SkinData):
	if !(Talo.current_player != null and Talo.current_alias != null): return

	# El SkinManager busca el record directamente del GameController
	var current_highscore = Talo.current_highscore 

	if current_highscore >= skin_to_save.required_score:
		Talo.current_player.set_prop("selected_skin", skin_to_save.skin_name)
		selected_skin = skin_to_save
		print("Skin permitida y guardada: ", skin_to_save.skin_name)
	else:
		print("¡INTENTO DE EQUIPAR SKIN BLOQUEADA! Puntos insuficientes.")
		
func load_skin_from_talo() -> SkinData:
	if Talo.current_player != null and Talo.current_alias != null:
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
	
func is_skin_unlocked(skin: SkinData) -> bool:
	var record = 0.0
	
	if Talo.current_player != null and Talo.current_alias != null:
		record = Talo.current_highscore
	
	return record >= skin.required_score
