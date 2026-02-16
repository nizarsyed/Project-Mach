extends Node3D
class_name MachineGun

const WeaponConfig = preload("res://_core/weapon_config.gd")

@export var config: WeaponConfig
@export var muzzle_point: Marker3D

var _current_heat: float = 0.0
var _fire_timer: float = 0.0

func _process(delta):
	_current_heat = move_toward(_current_heat, 0.0, (config.cooling_rate if config else 0.5) * delta)
	if _fire_timer > 0:
		_fire_timer -= delta

func fire(owner_velocity: Vector3):
	if not config: return
	if _fire_timer > 0: return
	if _current_heat >= 1.0: return

	_fire_timer = config.fire_rate
	_current_heat = min(_current_heat + config.heat_per_shot, 1.0)

	var forward = -global_transform.basis.z
	var final_dir = forward
	
	var best_target = _find_magnetism_target(forward)
	if best_target:
		var dir_to_target = (best_target.global_position - global_position).normalized()
		final_dir = forward.lerp(dir_to_target, config.magnetism_strength).normalized()
	
	var ray_origin = muzzle_point.global_position if is_instance_valid(muzzle_point) else global_position
	var ray_end = ray_origin + (final_dir * config.max_range)

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		if collider.has_method("take_damage"):
			collider.take_damage(config.damage)

func _find_magnetism_target(forward_dir: Vector3) -> Node3D:
	if config.magnetism_strength <= 0.01: return null
	
	var targets = get_tree().get_nodes_in_group("Targets")
	var best_target = null
	var best_dot = -1.0
	
	var threshold = cos(deg_to_rad(config.magnetism_angle_degrees))
	
	for t in targets:
		if not is_instance_valid(t): continue
		if t == self: continue
		
		var dir = (t.global_position - global_position).normalized()
		var dot = forward_dir.dot(dir)
		
		if dot > threshold and dot > best_dot:
			var dist = global_position.distance_to(t.global_position)
			if dist < config.max_range:
				best_dot = dot
				best_target = t
				
	return best_target
