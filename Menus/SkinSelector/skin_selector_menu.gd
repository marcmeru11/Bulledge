extends Control

# Ruta actualizada según tu jerarquía
@onready var grid = $CanvasLayer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	print("[Selector] Iniciando escena de skins...")
	await get_tree().process_frame
	
	# BLOQUEO CRÍTICO: Esperamos la respuesta de la red
	print("[Selector] Esperando respuesta de Talo Leaderboards...")
	await SkinManager.fetch_highscore_from_talo()
	
	# Debug del valor recuperado
	print("[Selector] Valor final recibido en el menú: ", SkinManager.player_highscore)
	
	display_skins()

func display_skins():
	if not grid:
		print("[Selector] ERROR: No se encontró el GridContainer en la ruta especificada.")
		return
	
	# Limpiamos los botones existentes
	for child in grid.get_children():
		child.queue_free()

	print("[Selector] Dibujando botones para ", SkinManager.all_skins.size(), " skins.")

	for skin in SkinManager.all_skins:
		var btn = Button.new()
		
		# Configuración visual
		btn.custom_minimum_size = Vector2(200, 230)
		btn.expand_icon = true
		btn.icon = skin.texture
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		
		# Lógica de bloqueo con Debug por skin
		var esta_desbloqueada = SkinManager.is_skin_unlocked(skin)
		print("[Selector] Skin: ", skin.skin_name, " | Req: ", skin.required_score, " | Desbloqueada: ", esta_desbloqueada)
		
		if esta_desbloqueada:
			btn.text = skin.skin_name
			btn.modulate = Color(1, 1, 1)
			btn.disabled = false
			btn.pressed.connect(_on_skin_selected.bind(skin))
		else:
			btn.disabled = true
			# Un gris un poco más claro (0.5) para que se vea la silueta
			btn.modulate = Color(0.5, 0.5, 0.5, 0.9) 
			btn.text = "BLOQUEADO\nReq: " + str(skin.required_score) + " pts"
		
		grid.add_child(btn)
	
	print("[Selector] Menú de skins generado completamente.")

func _on_skin_selected(skin: SkinData):
	print("[Selector] Seleccionando skin: ", skin.skin_name)
	SkinManager.save_skin_to_talo(skin)
	get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")

func _on_back_pressed():
	print("[Selector] Volviendo al menú principal...")
	get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")
