extends FlightPhysics
class_name EnemyAI

enum State { PATROL, ACQUIRE, CHASE, EVADE }

@export_group("AI Settings")
@export var update_rate: float = 0.1
@export var aggro_range: float = 2000.0
@export var target: Node3D
@export var patrol_point: Vector3
@export var flare_scene: PackedScene

var current_state: State = State.PATROL
var _ai_timer: float = 0.0

func _ready():
	super._ready()
	_ai_timer = randf() * update_rate

func _process(delta):
	_ai_timer -= delta
	if _ai_timer <= 0:
		_ai_timer = update_rate
		_think()

func _think():
	match current_state:
		State.PATROL:
			_state_patrol()
		State.ACQUIRE:
			_state_acquire()
		State.CHASE:
			_state_chase()
		State.EVADE:
			_state_evade()

func _state_patrol():
	_current_throttle = 0.6
	_steer_towards(patrol_point)
	if is_instance_valid(target) and global_position.distance_to(target.global_position) < aggro_range:
		current_state = State.ACQUIRE

func _state_acquire():
	current_state = State.CHASE

func _state_chase():
	if not is_instance_valid(target):
		current_state = State.PATROL
		return
	var dist = global_position.distance_to(target.global_position)
	if dist > aggro_range * 1.5:
		current_state = State.PATROL
		return
	var lead_pos = _predict_target_lead(target)
	_steer_towards(lead_pos)
	if dist > 500:
		_current_throttle = 1.0
	else:
		_current_throttle = 0.4

func _state_evade():
	_current_throttle = 1.0
	_input_roll = 1.0
	_input_pitch = 1.0

func _steer_towards(target_pos: Vector3):
	var my_transform = global_transform
	var direction_to_target = (target_pos - my_transform.origin).normalized()
	var local_target_dir = my_transform.basis.inverse() * direction_to_target
	_input_roll = clamp(-local_target_dir.x * 2.5, -1.0, 1.0)
	_input_pitch = clamp(local_target_dir.y * 3.0, -0.5, 1.0)
	_input_yaw = clamp(-local_target_dir.x * 0.5, -0.5, 0.5)

func _predict_target_lead(t: Node3D) -> Vector3:
	var dist = global_position.distance_to(t.global_position)
	var time = dist / 2000.0
	if "linear_velocity" in t:
		return t.global_position + (t.linear_velocity * time)
	return t.global_position

func on_missile_locked(missile: Node3D):
	current_state = State.EVADE
	if flare_scene:
		for i in range(3):
			var f = flare_scene.instantiate()
			get_parent().add_child(f)
			f.global_position = global_position - (global_transform.basis.z * 5.0)
			f.linear_velocity = linear_velocity + (Vector3(randf()-0.5, randf()-0.5, randf()-0.5) * 20.0)
