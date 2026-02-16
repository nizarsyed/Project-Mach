extends Camera3D
class_name CameraController

@export var target_vehicle: RigidBody3D
@export_group("Chase Settings")
@export var smooth_speed: float = 10.0
@export var offset: Vector3 = Vector3(0, 4, 10)
@export var look_ahead: float = 2.0

@export_group("Dynamic Effects")
@export var base_fov: float = 75.0
@export var max_fov: float = 95.0
@export var shake_decay: float = 5.0

var _shake_strength: float = 0.0
var _current_fov_mod: float = 0.0

func _ready():
	top_level = true

func _process(delta):
	if not is_instance_valid(target_vehicle):
		return
		
	var target_pos = target_vehicle.global_position
	var desired_pos = target_vehicle.global_transform.origin + (target_vehicle.global_transform.basis * offset)
	
	global_position = global_position.lerp(desired_pos, smooth_speed * delta)
	
	var vel_n = target_vehicle.linear_velocity.normalized() if target_vehicle.linear_velocity.length() > 1.0 else -target_vehicle.transform.basis.z
	var look_target = target_vehicle.global_position + (vel_n * look_ahead)
	
	look_at(look_target, Vector3.UP)
	
	var speed = target_vehicle.linear_velocity.length()
	var speed_factor = clamp((speed - 100.0) / 600.0, 0.0, 1.0)
	
	var desired_fov = lerp(base_fov, max_fov, speed_factor)
	fov = lerp(fov, desired_fov, 2.0 * delta)
	
	if _shake_strength > 0:
		_shake_strength = move_toward(_shake_strength, 0.0, shake_decay * delta)
		var offset_x = randf_range(-_shake_strength, _shake_strength)
		var offset_y = randf_range(-_shake_strength, _shake_strength)
		h_offset = offset_x
		v_offset = offset_y

func apply_shake(strength: float):
	_shake_strength = max(_shake_strength, strength)
