extends RigidBody3D
class_name FlightPhysics

const JetConfig = preload("res://_core/jet_config.gd")
const MachineGun = preload("res://components/combat/machine_gun.gd")

@export var config: JetConfig
@export var max_health: float = 100.0

var _current_throttle: float = 0.0
var _input_pitch: float = 0.0
var _input_roll: float = 0.0
var _input_yaw: float = 0.0
var _current_health: float = 0.0

var _forward_speed: float = 0.0
var _aoa_dot: float = 1.0
@onready var _machine_gun: MachineGun = get_node_or_null("MachineGun") as MachineGun

func _ready():
	custom_integrator = true
	linear_damp = 0.0
	angular_damp = 2.0
	_current_health = max_health
	
	if not config:
		printerr("FlightPhysics: No JetConfig assigned!")

func _process(_delta):
	if not is_in_group("Player"):
		return

	var input_manager = get_node_or_null("/root/InputManager")
	if not is_instance_valid(input_manager):
		return

	_input_pitch = float(input_manager.get("pitch_input"))
	_input_roll = float(input_manager.get("roll_input"))
	_input_yaw = float(input_manager.get("yaw_input"))
	_current_throttle = float(input_manager.get("throttle_input"))

	if bool(input_manager.get("fire_primary")) and is_instance_valid(_machine_gun):
		_machine_gun.fire(linear_velocity)

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if not config: return
	
	var dt = state.step
	var transform = state.transform
	var velocity = state.linear_velocity
	
	var local_vel = transform.basis.inverse() * velocity
	_forward_speed = -local_vel.z
	
	# 1. Thrust
	var thrust_mult = 1.0
	if config.acceleration_curve:
		thrust_mult = config.acceleration_curve.sample_baked(_forward_speed / config.max_speed)
	
	var thrust_force = -transform.basis.z * (_current_throttle * 200000.0 * thrust_mult)
	state.apply_central_force(thrust_force)
	
	# 2. Lift
	var lift_dir = transform.basis.y
	var lift_mag = _forward_speed * config.lift_coefficient * config.mass * 0.1
	state.apply_central_force(lift_dir * lift_mag)
	
	# 3. Drag
	var drag_force = -velocity.normalized() * (velocity.length_squared() * config.drag_coefficient)
	state.apply_central_force(drag_force)
	
	# Induced Drag
	var movement_dir = velocity.normalized()
	var heading_dir = -transform.basis.z
	_aoa_dot = movement_dir.dot(heading_dir)
	var drift_factor = 1.0 - abs(_aoa_dot)
	
	if drift_factor > 0.05:
		var induced_drag = -movement_dir * (velocity.length_squared() * 2.0 * drift_factor)
		state.apply_central_force(induced_drag)
	
	# 4. Torque
	var authority = 1.0
	if config.turn_authority_curve:
		authority = config.turn_authority_curve.sample_baked(_forward_speed / config.max_speed)
	
	var torque = Vector3.ZERO
	torque += transform.basis.x * _input_pitch * config.pitch_speed
	torque += transform.basis.z * _input_roll * config.roll_speed
	torque += transform.basis.y * _input_yaw * config.yaw_speed
	
	state.apply_torque(torque * authority * config.mass * 100.0)

func take_damage(amount: float):
	if amount <= 0.0:
		return

	_current_health -= amount
	if _current_health <= 0.0:
		_destroy_vehicle()

func _destroy_vehicle():
	queue_free()
