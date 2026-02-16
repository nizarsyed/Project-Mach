extends RigidBody3D
class_name Missile

@export_group("Guidance")
@export var nav_constant: float = 3.0
@export var max_turn_rate: float = 2.5
@export var max_speed: float = 600.0
@export var acceleration: float = 200.0 
@export var arming_delay: float = 0.5

@export var aero_turn_smoothness: float = 6.0
@export var aero_drag_smoothness: float = 4.0

@export_group("Stats")
@export var fuel_time: float = 8.0
@export var damage: float = 50.0
@export var flare_distraction_chance: float = 0.8

var target: Node3D
var _time_alive: float = 0.0
var _last_los: Vector3 = Vector3.ZERO
var _current_speed: float = 0.0

func _ready():
	continuous_cd = true 
	can_sleep = false
	custom_integrator = true
	contact_monitor = true
	max_contacts_reported = 1

func launch(start_transform: Transform3D, initial_velocity: Vector3, new_target: Node3D):
	global_transform = start_transform
	linear_velocity = initial_velocity + (-start_transform.basis.z * 50.0) 
	_current_speed = linear_velocity.length()
	target = new_target
	
	if is_instance_valid(target):
		_last_los = (target.global_position - global_position).normalized()
	else:
		_last_los = -start_transform.basis.z

func _integrate_forces(state: PhysicsDirectBodyState3D):
	var dt = state.step
	if dt <= 0.0001: return
	
	_time_alive += dt
	if _time_alive > fuel_time:
		explode()
		return
		
	if _current_speed < max_speed:
		_current_speed += acceleration * dt
	
	var current_pos = state.transform.origin
	var current_vel = state.linear_velocity
	var forward = -state.transform.basis.z
	
	var command_turn_vec = Vector3.ZERO
	
	if is_instance_valid(target) and _time_alive > arming_delay:
		var target_pos = target.global_position
		var los_vector = (target_pos - current_pos).normalized()
		
		if _last_los == Vector3.ZERO:
			_last_los = los_vector

		var target_vel = Vector3.ZERO
		if target is RigidBody3D:
			target_vel = target.linear_velocity
		elif "velocity" in target:
			target_vel = target.velocity
		
		if not (target is Flare) and randf() < (flare_distraction_chance * dt * 5.0):
			_check_for_flares()
			
		var rel_vel = target_vel - current_vel
		var closing_speed = -rel_vel.dot(los_vector)
		var speed_safe = max(_current_speed, 1.0)
		
		var velocity_ratio = clamp(closing_speed / speed_safe, 0.5, 3.0) 
		var los_rate_vec = _last_los.cross(los_vector) / dt
		
		command_turn_vec = los_rate_vec * nav_constant * velocity_ratio
		
		if command_turn_vec.length() > max_turn_rate:
			command_turn_vec = command_turn_vec.normalized() * max_turn_rate
			
		_last_los = los_vector
	
	state.angular_velocity = state.angular_velocity.lerp(command_turn_vec, aero_turn_smoothness * dt)
	
	var desired_velocity = forward * _current_speed
	state.linear_velocity = state.linear_velocity.lerp(desired_velocity, aero_drag_smoothness * dt)

func _on_body_entered(body):
	if body == self: return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	explode()

func _check_for_flares():
	var flares = get_tree().get_nodes_in_group("Flares")
	var best_flare = null
	var best_dist = 99999.0
	
	for f in flares:
		var dist = global_position.distance_to(f.global_position)
		if dist < 500.0 and dist < best_dist:
			var dir = (f.global_position - global_position).normalized()
			var forward = -global_transform.basis.z
			if forward.dot(dir) > 0.5:
				best_dist = dist
				best_flare = f
	
	if best_flare:
		target = best_flare

func explode():
	queue_free()
