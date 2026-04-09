extends Control

@onready var register_btn: Button = $CanvasLayer/VBoxContainer/Register
@onready var login_btn: Button = $CanvasLayer/VBoxContainer/log_in
@onready var play_btn: Button = $CanvasLayer/VBoxContainer/play
@onready var leaderboard_btn: Button = $CanvasLayer/VBoxContainer/leaderboard
# Nueva referencia a tu Label
@onready var logged_in_label: Label = $CanvasLayer/VBoxContainer/loggedIn

func _ready() -> void:
	check_talo_status()

func check_talo_status() -> void:
	if Talo:
		update_menu_visibility()
	else:
		logged_in_label.text = "ERROR: Talo no activo"
		logged_in_label.modulate = Color.RED

func update_menu_visibility() -> void:
	# Verificación estricta: Jugador + Alias (Nombre)
	var is_logged: bool = Talo.current_player != null and Talo.current_alias != null
	
	play_btn.visible = is_logged
	leaderboard_btn.visible = is_logged
	
	register_btn.visible = !is_logged
	login_btn.visible = !is_logged
	
	# --- ACTUALIZACIÓN DE LA LABEL ---
	if is_logged:
		logged_in_label.text = "Logged in as " + Talo.current_alias.identifier
		logged_in_label.modulate = Color.GREEN
	else:
		logged_in_label.text = "Not logged in"
		logged_in_label.modulate = Color.ORANGE
		
	# Debug para consola
	if Talo.current_player and not Talo.current_alias:
		print("Estado: Jugador detectado pero sin alias (provisional)")

# --- NAVEGACIÓN ---

func _on_log_in_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/LogInMenu/log_in_menu.tscn")

func _on_register_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/RegisterMenu/register_menu.tscn")

func _on_leaderboard_pressed() -> void:
	get_tree().change_scene_to_file("res://Menus/leaderboard/leaderboard.tscn")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/level.tscn")

func _on_logout_pressed() -> void:
	Talo.player_auth.logout()
	update_menu_visibility()
