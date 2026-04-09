extends Control

signal verification_required

# Rutas basadas exactamente en tu árbol de nodos
@onready var username_input: LineEdit = $CanvasLayer/VBoxContainer/Username
@onready var password_input: LineEdit = $CanvasLayer/VBoxContainer/Password
@onready var validation_label: Label = $CanvasLayer/VBoxContainer/ErrorLabel
@onready var login_button: Button = $CanvasLayer/VBoxContainer/LogIn

func _ready() -> void:
	validation_label.text = ""

func _on_back_pressed() -> void:
	# Forzamos el cierre de cualquier sesión provisional antes de irnos
	if Talo.current_player:
		Talo.player_auth.logout()
	
	get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")
	
func _on_log_in_pressed() -> void:
	# 1. Validar que no estén vacíos
	if username_input.text.strip_edges().is_empty() or password_input.text.strip_edges().is_empty():
		validation_label.text = "Por favor, rellena todos los campos"
		return

	login_button.disabled = true
	validation_label.text = "Iniciando sesión..."

	# 2. Ejecutar el Login (tu lógica de Talo)
	var res := await Talo.player_auth.login(username_input.text, password_input.text)
	
	match res:
		Talo.player_auth.LoginResult.FAILED:
			login_button.disabled = false
			# Manejo de errores
			var error = Talo.player_auth.last_error
			if error and error.get_code() == TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
				validation_label.text = "Usuario o contraseña incorrectos"
			else:
				validation_label.text = error.get_string() if error else "Error de conexión"
		
		Talo.player_auth.LoginResult.VERIFICATION_REQUIRED:
			verification_required.emit()
			validation_label.text = "Se requiere verificación"
			
		Talo.player_auth.LoginResult.OK:
			validation_label.text = "¡Éxito! Entrando..."
			# Esperamos un segundo para que el usuario vea el mensaje de éxito
			await get_tree().create_timer(1.0).timeout
			# Cambia esto por tu escena de juego real
			get_tree().change_scene_to_file("res://Menus/MainMenu/main_menu.tscn")
