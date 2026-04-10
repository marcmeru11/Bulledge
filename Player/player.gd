extends CharacterBody2D

signal death

# --- VARIABLES DE SKIN ---
var current_skin: SkinData 

@export var friction: float = 0.9
@export var acceleration: float = 750
@export var max_speed: float = 1500

var dead = false

func _ready() -> void:
	await get_tree().process_frame
	
	print("[Player] Solicitando skin al SkinManager...")
	var skin_a_usar = await SkinManager.get_active_skin()
	
	if skin_a_usar:
		apply_skin(skin_a_usar)
		print("[Player] Skin aplicada con éxito: ", skin_a_usar.skin_name)
	else:
		print("[Player] ERROR: No se pudo cargar ninguna skin, usando textura por defecto del nodo.")

# --- FUNCIÓN PARA APLICAR LA SKIN ---
func apply_skin(data: SkinData) -> void:
	if data == null: 
		return
		
	current_skin = data
	
	# Verificamos que el nodo Sprite2D existe para evitar errores
	if has_node("Sprite2D"):
		$Sprite2D.texture = data.texture
		# Si tienes un color de estela o partículas en tu SkinData, podrías usar:
		# $Sprite2D.modulate = data.trail_color 
	else:
		print("[Player] ERROR: No se encontró el nodo Sprite2D")

func _physics_process(delta: float) -> void:
	if dead: return
	
	move(Input.get_axis("left", "right"), Input.get_axis("up", "down"), delta)
	apply_max_speed()
	move_and_slide()

func apply_friction(mode: bool):
	if mode:
		velocity.x *= friction
	else:
		velocity.y *= friction

func move(x: float, y: float, delta: float):
	if dead:
		return
		
	# Movimiento Horizontal
	if x != 0:
		velocity.x += acceleration * delta * x
	else:
		apply_friction(true)
		
	# Movimiento Vertical
	if y != 0:
		velocity.y += acceleration * delta * y
	else:
		apply_friction(false)

func apply_max_speed():
	# clamp() devuelve el valor limitado, hay que reasignarlo
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Asumiendo que el Area2D es un hijo del Player para detectar choques
	if body.is_in_group("Enemy") and not dead:
		dead = true
		death.emit()
		print("[Player] Ha muerto.")
