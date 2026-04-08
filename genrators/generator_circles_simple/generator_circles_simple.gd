extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var despawntime: float = 1
@export var spawn_time_limits: Vector2 = Vector2(1,5)
@export var num_bullets_limits: Vector2i = Vector2i(20, 40)
@export var rotation_speed: float = 10
@export var bullet_speed_limits: Vector2 = Vector2(100,300)
@export var max_shots_num: int = 3
@export var time_between_shots: Vector2i = Vector2i(0.5, 0.3)

var angle_offset: float = 0
var num_bullets: int
var shots: int
var current_shots: int = 0
var time_wait_shots

var bullet_speed:float 
var colors = [Color("ff49ff"), Color("9c49ff"), Color("0449ff"), Color("ffff35"), Color("27ff35"),  Color("27ffee"), Color("ff4215"),  Color("ffffff"), Color("89f5ff"),  Color("ff8d00"),]
var color

func _ready() -> void:
	time_wait_shots = randf_range(time_between_shots.x, time_between_shots.y)
	shots = randi_range(1, max_shots_num)
	$AnimationPlayer.play("spawn")
	num_bullets = randi_range(num_bullets_limits.x, num_bullets_limits.y)
	color = colors[randi_range(0, len(colors) -1)]
	bullet_speed = randf_range(bullet_speed_limits.x, bullet_speed_limits.y)
	modulate = color
	
	$Timer.start(randf_range(spawn_time_limits.x, spawn_time_limits.y))

func _on_timer_timeout() -> void:
	shoot_in_circle()

func _on_dead_timer_timeout() -> void:
	get_parent().despawned()
	$AnimationPlayer.play("despawn")

func shoot_in_circle():
	current_shots += 1
	for i in range(num_bullets):
		var bullet = bullet_scene.instantiate()
		var base_angle = (2 * PI / num_bullets) * i
		var angle = base_angle + ((PI / num_bullets)*(current_shots%2))
		bullet.position = position
		bullet.direction = Vector2(cos(angle), sin(angle))
		bullet.speed = bullet_speed
		bullet.modulate = color
		get_parent().add_child(bullet)
	if current_shots >= shots:
		$Dead_Timer.start(despawntime)
	else: 
		$Timer.start(time_wait_shots)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "despawn":
		queue_free()
