extends Control

@onready var grid = $ScrollContainer/GridContainer

func _ready():
	display_skins()

func display_skins():
	# Limpiamos el grid por si acaso
	for child in grid.get_children():
		child.queue_free()
	
	# Obtenemos el record actual para saber qué bloquear
	# Accedemos al high_score que guardamos en el GameController o Talo
	var current_record = 0.0
	if Talo.current_player:
		# Aquí podrías pedir el record a Talo o pasarle el dato desde el GameController
		pass 

	for skin in SkinManager.all_skins:
		var btn = Button.new()
		btn.text = skin.skin_name
		btn.custom_minimum_size = Vector2(150, 150)
		
		# Ponemos la imagen de la skin en el botón
		btn.icon = skin.texture
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		
		# Lógica de bloqueo: si requiere más puntos de los que tenemos
		# (Asumiendo que tienes el high_score accesible)
		# if skin.required_score > current_record:
		#	btn.disabled = true
		#	btn.modulate = Color(0.3, 0.3, 0.3) # Oscurecer
		
		# Conectamos el clic del botón
		btn.pressed.connect(_on_skin_selected.bind(skin))
		
		grid.add_child(btn)

func _on_skin_selected(skin: SkinData):
	SkinManager.selected_skin = skin
	SkinManager.save_skin_to_talo(skin.skin_name)
	print("Seleccionada y guardada: ", skin.skin_name)
	# Opcional: Volver al menú principal o cerrar el selector
	get_tree().change_scene_to_file("res://Menus/MainMenu.tscn")
