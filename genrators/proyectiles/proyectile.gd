extends CharacterBody2D

@export var speed: float = 200
@export var direction: Vector2 = Vector2.ZERO
@export var rotation_speed: float = 360 

	
func _process(delta):
	position += direction * speed * delta
	rotation += deg_to_rad(rotation_speed * delta) 

func clear():
	queue_free()
