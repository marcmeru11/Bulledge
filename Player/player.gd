extends CharacterBody2D

signal death

var current_skin: SkinData 

@export var friction: float = 0.75
@export var acceleration: float = 1000
@export var max_speed: float = 1000
@export var dash_active: bool = false
@export var dash_cooldown: float = 1.0
@export var teleport_distance: float = 200.0

var is_moving: bool = false
var dead:bool = false
var dash_available: bool = true

@onready var dash_particles = $DashParticles

func _ready() -> void:
	await get_tree().process_frame
	var skin_a_usar = SkinManager.get_active_skin()
	if skin_a_usar:
		apply_skin(skin_a_usar)

func apply_skin(data: SkinData) -> void:
	if data == null: return
	current_skin = data
	if has_node("Sprite2D"):
		$Sprite2D.texture = data.texture

func _physics_process(delta: float) -> void:
	if dead: return
	var control_directions = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	
	if dash_active: dash(control_directions)
	move(control_directions, delta)
	apply_max_speed()
	move_and_slide()

func move(control_directions: Vector2, delta: float):
	var direction = control_directions.normalized()
	
	if direction.x != 0:
		velocity.x += acceleration * delta * direction.x
	else:
		velocity.x *= friction
		
	if direction.y != 0:
		velocity.y += acceleration * delta * direction.y
	else:
		velocity.y *= friction

func dash(control_directions: Vector2):
	if Input.is_key_pressed(KEY_SPACE) or Input.is_action_just_pressed("ui_accept"):
		if not dead and dash_available and control_directions != Vector2.ZERO:
			dash_available = false
			dash_active = true
			
			if dash_particles:
				dash_particles.restart()
				dash_particles.emitting = true
			
			var teleport_vector = control_directions.normalized() * teleport_distance
			move_and_collide(teleport_vector)
			
			await get_tree().create_timer(dash_cooldown).timeout
			dash_available = true
			dash_active = false

func apply_max_speed():
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and not dead:
		dead = true
		death.emit()
