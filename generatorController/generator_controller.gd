extends Node

@export var min_spawn_time: float = 0.5
@export var max_spawn_time: float = 3
@export var min_spawn_pos: Vector2i = Vector2i(475,50)
@export var max_spawn_pos: Vector2i = Vector2i(1403, 1060)
@export var spawner_A:PackedScene
@export var spawner_B:PackedScene
@export var spawner_C:PackedScene

@export var player: CharacterBody2D
@export var generators_limits: int = 3

var num_generators = 0
var spawner = null

func _ready() -> void:
	$SpawnTimer.start(randf_range(min_spawn_time, max_spawn_time))

func _on_spawn_timer_timeout() -> void:
	if num_generators >= generators_limits:
		$SpawnTimer.start(randf_range(min_spawn_time, max_spawn_time))
		return
	
	spawn_choice()
	num_generators += 1
	var x: int
	var y: int

	# Generar posición X aleatoria, asegurando que esté lejos del jugador
	var attempts = 10  # Máximo intentos para evitar bucles infinitos
	while attempts > 0:
		x = randi_range(min_spawn_pos.x, max_spawn_pos.x)
		if abs(player.position.x - x) > 100:
			break
		attempts -= 1

	# Generar posición Y aleatoria, asegurando que esté lejos del jugador
	attempts = 10
	while attempts > 0:
		y = randi_range(min_spawn_pos.y, max_spawn_pos.y)
		if abs(player.position.y - y) > 100:
			break
		attempts -= 1

	# Instanciar el objeto y asignar la posición generada
	var instance = spawner.instantiate()
	instance.position = Vector2(x, y)
	add_child(instance)  # Asegurar que se agregue a la escena

	# Reiniciar el temporizador con un tiempo aleatorio
	$SpawnTimer.start(randf_range(min_spawn_time, max_spawn_time))

func despawned():
	num_generators -= 1
	
func spawn_choice():
	var num = randi_range(0,1)
	match num:
		0: spawner = spawner_A
		1: spawner = spawner_B
			
