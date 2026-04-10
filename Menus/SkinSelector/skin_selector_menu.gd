extends Control

# Ruta al GridContainer basándome en tu imagen de jerarquía
@onready var grid = $CanvasLayer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	# Esperamos un frame para que el SkinManager tenga tiempo de cargar todo
	await get_tree().process_frame
	display_skins()

func display_skins():
	if not grid:
		print("Error: No se encontró el GridContainer")
		return
	
	# Limpiamos los botones que pudieran existir de antes
	for child in grid.get_children():
		child.queue_free()

	print("Cargando menú para ", SkinManager.all_skins.size(), " skins.")

	for skin in SkinManager.all_skins:
		var btn = Button.new()
		
		# Configuración visual del botón
		btn.custom_minimum_size = Vector2(200, 230) # Tamaño cuadrado grande
		btn.expand_icon = true
		btn.icon = skin.texture
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		
		# --- LÓGICA DE BLOQUEO ---
		# Usamos la función que creamos en el SkinManager
		var esta_desbloqueada = SkinManager.is_skin_unlocked(skin)
		
		if esta_desbloqueada:
			# Si está desbloqueada, el botón funciona normal
			btn.text = skin.skin_name
			btn.modulate = Color(1, 1, 1) # Color normal (blanco)
			btn.disabled = false
			
			# Conectamos el clic para guardar la skin
			btn.pressed.connect(_on_skin_selected.bind(skin))
		else:
			# Si está bloqueada, desactivamos el botón y lo ponemos oscuro
			btn.disabled = true
			btn.modulate = Color(0.3, 0.3, 0.3, 0.8) # Gris oscuro y algo transparente
			btn.text = "BLOQUEADO\nReq: " + str(skin.required_score) + " pts"
		
		grid.add_child(btn)

func _on_skin_selected(skin: SkinData):
	# Guardamos la skin seleccionada en Talo y en la variable local
	SkinManager.save_skin_to_talo(skin)
	
	print("Has equipado: ", skin.skin_name)
	
	# Cambiamos a la escena del juego (ajusta la ruta a tu escena real)
	get_tree().change_scene_to_file("res://scenes/world.tscn")

# Función para el botón físico de "BACK TO MAIN MENU" si lo tienes conectado por señal
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
