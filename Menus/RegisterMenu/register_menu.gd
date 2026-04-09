extends Control

# Usamos rutas directas para evitar el error de "%"
@onready var username: LineEdit = $CanvasLayer/VBoxContainer/Username
@onready var email: LineEdit = $CanvasLayer/VBoxContainer/Email
@onready var password: LineEdit = $CanvasLayer/VBoxContainer/Password
@onready var password_confirmation: LineEdit = $CanvasLayer/VBoxContainer/Password_confirmation
@onready var validation_label: Label = $CanvasLayer/VBoxContainer/ErrorLabel
@onready var register_button: Button = $CanvasLayer/VBoxContainer/Register

func _on_back_pressed() -> void:
	# Forzamos el cierre de cualquier sesión provisional antes de irnos
	if Talo.current_player:
		Talo.player_auth.logout()
	
	get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")
	
	
func _on_register_pressed() -> void:
	# 1. Validaciones básicas
	if username.text.is_empty() or password.text.is_empty() or email.text.is_empty():
		validation_label.text = "Rellena todos los campos"
		return
		
	if password.text != password_confirmation.text:
		validation_label.text = "Las contraseñas no coinciden"
		return

	register_button.disabled = true
	validation_label.text = "Registrando..."

	# 2. Llamada a Talo (usando el formato que pasaste)
	# Fíjate que añadimos 'false' al final para la verificación de email
	var res = await Talo.player_auth.register(username.text, password.text, email.text, false)
	
	# 3. Manejo de respuesta
	if res == OK:
		validation_label.text = "¡Éxito! Redirigiendo..."
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")
	else:
		register_button.disabled = false
		# Mostramos el error que nos devuelve Talo
		if Talo.player_auth.last_error:
			validation_label.text = Talo.player_auth.last_error.get_string()
		else:
			validation_label.text = "Error desconocido en el registro"
