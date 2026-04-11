extends Control

@onready var grid = $CanvasLayer/VBoxContainer/ScrollContainer/GridContainer

func _ready():
	print("[Selector] Iniciando escena de skins...")
	await get_tree().process_frame
	
	print("[Selector] Esperando respuesta de Talo Leaderboards...")
	await SkinManager.fetch_highscore_from_talo()
	
	# NUEVO: Pedimos la skin activa antes de dibujar los botones
	print("[Selector] Obteniendo skin equipada actual...")
	var active_skin = SkinManager.get_active_skin()
	
	print("[Selector] Valor final recibido en el menú: ", SkinManager.player_highscore)
	
	# Le pasamos la skin activa a la función
	display_skins(active_skin)

func display_skins(active_skin: SkinData):
	if not grid:
		print("[Selector] ERROR: No se encontró el GridContainer.")
		return
	
	for child in grid.get_children():
		child.queue_free()

	print("[Selector] Dibujando botones para ", SkinManager.all_skins.size(), " skins.")

	for skin in SkinManager.all_skins:
		var btn = Button.new()
		
		btn.custom_minimum_size = Vector2(200, 230)
		btn.expand_icon = true
		btn.icon = skin.texture
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		
		# --- NUEVO: Creamos el estilo base con esquinas redondeadas ---
		var base_style = StyleBoxFlat.new()
		base_style.bg_color = Color(0.15, 0.15, 0.15, 1) # Gris oscuro para el fondo
		base_style.corner_radius_top_left = 15
		base_style.corner_radius_top_right = 15
		base_style.corner_radius_bottom_left = 15
		base_style.corner_radius_bottom_right = 15
		
		var esta_desbloqueada = SkinManager.is_skin_unlocked(skin)
		
		if esta_desbloqueada:
			# Comprobamos si esta es la skin que llevamos puesta
			if active_skin != null and skin.skin_name == active_skin.skin_name:
				btn.text = skin.skin_name + "\n(Equipada)"
				btn.disabled = true
				
				# --- ESTILO EQUIPADA: Le añadimos el borde rojo ---
				var equipped_style = base_style.duplicate()
				equipped_style.border_width_left = 3
				equipped_style.border_width_right = 3
				equipped_style.border_width_top = 3
				equipped_style.border_width_bottom = 3
				equipped_style.border_color = Color("cc2446")
				
				btn.add_theme_stylebox_override("disabled", equipped_style)
			else:
				btn.text = skin.skin_name
				btn.disabled = false
				btn.pressed.connect(_on_skin_selected.bind(skin))
				
				btn.add_theme_stylebox_override("normal", base_style)
				
				var hover_style = base_style.duplicate()
				hover_style.bg_color = Color(0.25, 0.25, 0.25, 1) 
				btn.add_theme_stylebox_override("hover", hover_style)
				btn.add_theme_stylebox_override("pressed", base_style)
		else:
			btn.disabled = true
			btn.modulate = Color(0.5, 0.5, 0.5, 0.9) 
			btn.text = "BLOQUEADO\nReq: " + str(skin.required_score) + " pts"
			
			var locked_style = base_style.duplicate()
			locked_style.bg_color = Color(0.1, 0.1, 0.1, 1) 
			btn.add_theme_stylebox_override("disabled", locked_style)
		
		grid.add_child(btn)
	
	print("[Selector] Menú de skins generado completamente.")

func _on_skin_selected(skin: SkinData):
	print("[Selector] Seleccionando skin: ", skin.skin_name)
	SkinManager.save_skin_to_talo(skin)
	get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")

func _on_back_pressed():
	print("[Selector] Volviendo al menú principal...")
	get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")
