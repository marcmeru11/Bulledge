extends Node

const SAVE_FILE = "user://save.cfg"

func save_high_score(score: float):
	var config = ConfigFile.new()
	config.set_value("data", "high_score", score)
	config.save(SAVE_FILE)

func load_high_score() -> float:
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE)
	
	if err == OK:
		return config.get_value("data", "high_score", 0)
	return -1

func reset_save():
	var save_path = "user://save.cfg"
	
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)  # Elimina el archivo
		print("Archivo de guardado eliminado.")
		
