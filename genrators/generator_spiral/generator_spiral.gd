extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var despawntime: float = 1
@export var spawn_time_limits: Vector2 = Vector2(1,5)
@export var num_bullets_limits: Vector2i = Vector2i(20, 40)
@export var rotation_speed: float = 5
@export var time_between_shoots: float = 0.1
@export var bullet_speed_limits: Vector2 = Vector2(100,300)
@export var initial_angle_offset_limits: Vector2 = Vector2(0, 360)

var initial_angle_offset: float
var angle_offset: float = 0
var num_bullets: int

var bullet_speed:float 
var colors = [Color("ff49ff"), Color("9c49ff"), Color("0449ff"), Color("ffff35"), Color("27ff35"),  Color("27ffee"), Color("ff4215"),  Color("ffffff"), Color("89f5ff"),  Color("ff8d00"),]
var color

func _ready() -> void:
	$AnimationPlayer.play("spawn")
	num_bullets = randi_range(num_bullets_limits.x, num_bullets_limits.y)
	color = colors[randi_range(0, len(colors) -1)]
	bullet_speed = randf_range(bullet_speed_limits.x, bullet_speed_limits.y)
	modulate = color
	$Timer.start(randf_range(spawn_time_limits.x, spawn_time_limits.y))
	initial_angle_offset = randf_range(initial_angle_offset_limits.x, initial_angle_offset_limits.y)
	angle_offset += initial_angle_offset

func _on_timer_timeout() -> void:
	shoot_in_spiral()

func _on_dead_timer_timeout() -> void:
	get_parent().despawned()
	$AnimationPlayer.play("despawn")
	
func shoot_in_spiral():
	var a = 1
	var b = 4
	for i in range(a,b):
		var bullet = bullet_scene.instantiate()
		var angle = deg_to_rad(angle_offset + (360.0/(b-1))*i)  # Convertir el ángulo a radianes
		bullet.position = position
		bullet.direction = Vector2(cos(angle), sin(angle))
		bullet.speed = bullet_speed
		bullet.modulate = color
		get_parent().add_child(bullet)

		angle_offset += rotation_speed
	
	if angle_offset - initial_angle_offset > 360:
		$shooterTimer.stop()
		$Dead_Timer.start(despawntime)
	else: 
		$shooterTimer.start(time_between_shoots)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "despawn":
		queue_free()
