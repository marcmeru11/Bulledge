extends Control

@export var item_scene: PackedScene 
@export var leaderboard_name: String = "Month"

@onready var items_list: VBoxContainer = $CanvasLayer/VBoxContainer/ScrollContainer/List
@onready var title_label: Label = $CanvasLayer/VBoxContainer/Label

func _ready() -> void:
	load_leaderboard()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		back()

func _on_back_pressed() -> void:
	back()

func load_leaderboard() -> void:
	# 1. Limpieza total
	for child in items_list.get_children():
		child.queue_free()
	
	if !Talo.current_player:
		title_label.text = "INICIA SESIÓN"
		return
	
	title_label.text = "CARGANDO..."
	
	# 2. Pedimos los registros a Talo
	var options = Talo.leaderboards.GetEntriesOptions.new()
	var res = await Talo.leaderboards.get_entries(leaderboard_name, options)
	
	if not res or res.entries.size() == 0:
		title_label.text = "SIN PUNTUACIONES"
		return

	title_label.text = "TOP 15"
	
	var am_i_in_top: bool = false
	var my_id = Talo.current_player.id
	
	# 3. Mostrar solo los primeros 15
	var limit = min(res.entries.size(), 15)
	for i in range(limit):
		var entry = res.entries[i]
		create_item(entry)
		
		# Comprobamos si soy yo uno de estos 15
		var alias = entry.get("player_alias")
		if alias and alias.get("player_id") == my_id:
			am_i_in_top = true

	# 4. Si NO estoy en el Top 15, me busco y me añado al final
	if not am_i_in_top:
		# Buscamos mi entrada específica en todos los registros devueltos
		var my_entry = null
		for entry in res.entries:
			var alias = entry.get("player_alias")
			if alias and alias.get("player_id") == my_id:
				my_entry = entry
				break
		
		# Si encontré mi entrada fuera del top 15, la añado con un separador
		if my_entry:
			add_separator()
			create_item(my_entry)

func create_item(entry) -> void:
	var item = item_scene.instantiate()
	items_list.add_child(item)
	
	var row = item.get_node("HBoxContainer")
	var alias = entry.get("player_alias")
	
	var p_name = alias.get("identifier") if alias else "Anónimo"
	var p_rank = str(entry.get("position") + 1)
	var final_score = float(entry.get("score")) / 10.0
	
	row.get_node("Position").text = "#" + p_rank
	row.get_node("Name").text = p_name
	row.get_node("Points").text = str(final_score) + "s"
	
	# Resaltado si soy yo
	if alias and alias.get("player_id") == Talo.current_player.id:
		row.get_node("Name").modulate = Color.YELLOW
		row.get_node("Points").modulate = Color.YELLOW

func add_separator() -> void:
	var sep = Label.new()
	sep.text = "..."
	sep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	items_list.add_child(sep)


func back() -> void:
	get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")
	
