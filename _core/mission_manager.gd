extends Node
class_name MissionManager

const EnemyAI = preload("res://components/flight/enemy_ai.gd")

signal wave_started(wave_num: int)
signal mission_complete(score: int)
signal mission_check_point(msg: String)

@export var enemy_spawner: Node3D
@export var enemy_scene: PackedScene
@export var waves: Array = [2, 4, 6] # Enemy count per wave

var current_wave_index: int = 0
var active_enemies: int = 0
var score: int = 0
var game_active: bool = false

func _ready():
	if enemy_scene and enemy_spawner:
		call_deferred("start_mission")
	else:
		push_warning("MissionManager: enemy_scene or enemy_spawner is not configured.")

func start_mission():
	score = 0
	current_wave_index = 0
	game_active = true
	_start_next_wave()

func _start_next_wave():
	if current_wave_index >= waves.size():
		emit_signal("mission_complete", score)
		game_active = false
		return
		
	var count = waves[current_wave_index]
	emit_signal("wave_started", current_wave_index + 1)
	
	_spawn_enemies(count)
	current_wave_index += 1

func _spawn_enemies(count: int):
	if not enemy_scene or not enemy_spawner:
		active_enemies = 0
		return

	active_enemies = count
	var player = get_tree().get_first_node_in_group("Player") as Node3D
	var parent_node = enemy_spawner.get_parent() if is_instance_valid(enemy_spawner.get_parent()) else self

	for i in range(count):
		var enemy = enemy_scene.instantiate()
		parent_node.add_child(enemy)
		# Random position around spawner
		enemy.global_position = enemy_spawner.global_position + Vector3(randf_range(-1000, 1000), randf_range(500, 1000), randf_range(-1000, 1000))
		if enemy is EnemyAI and is_instance_valid(player):
			enemy.target = player
		# Connect 'tree_exited' or custom signal 'died'
		enemy.tree_exited.connect(_on_enemy_died)

func _on_enemy_died():
	if not game_active: return
	score += 100
	active_enemies -= 1
	
	if active_enemies <= 0:
		call_deferred("_start_next_wave")

func fail_mission():
	game_active = false
	# Show Game Over UI
