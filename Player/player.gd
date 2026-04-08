extends CharacterBody2D

signal death

@export var friction = 0.9
@export var acceleration = 750
@export var max_speed = 1500

var dead = false

func _physics_process(delta: float) -> void:
	move(Input.get_axis("left", "right"), Input.get_axis("up", "down"), delta)
	apply_max_speed()
	
	move_and_slide()

func apply_friction(mode:bool):
	if mode:
		velocity.x *= friction
	else:
		velocity.y *= friction

func move(x: float, y :float, delta: float):
	if dead:
		return
	if x != 0:
		velocity.x += acceleration*delta*x
	else:
		apply_friction(true)
	if y != 0:
		velocity.y += acceleration*delta*y
	else:
		apply_friction(false)

func apply_max_speed():
	clamp(velocity.x, -max_speed, max_speed)
	clamp(velocity.y, -max_speed, max_speed)
		


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and not dead:
		dead = true
		death.emit()
