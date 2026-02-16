extends Control
class_name Radar

@export var player: Node3D
@export var radar_range: float = 3000.0
@export var update_rate: float = 0.06 # ~15Hz
@export var blip_scene: PackedScene

var _timer: float = 0.0
var _blip_pool: Array = [] # Object pooling for blips
var _active_blips: Dictionary = {} # Node3D -> Control

func _ready():
	# Find player if not assigned
	if not player:
		player = get_tree().get_first_node_in_group("Player")

func _process(delta):
	_timer -= delta
	if _timer <= 0:
		_timer = update_rate
		_update_radar()

func _update_radar():
	if not is_instance_valid(player): return
	
	var targets = get_tree().get_nodes_in_group("RadarTarget")
	var player_pos = player.global_position
	var player_forward = -player.global_transform.basis.z
	var player_right = player.global_transform.basis.x
	
	# Clear old? Or pool?
	# For prototype, hide all, then show used
	for k in _active_blips:
		_active_blips[k].visible = false
		
	for t in targets:
		if t == player: continue
		
		# Relative position
		var rel_pos = t.global_position - player_pos
		var dist = rel_pos.length()
		
		if dist > radar_range: continue
		
		# Project to 2D (Top Down relative to player heading)
		# Z is forward (up on radar), X is right
		# We need to project world relative pos onto player basis
		var local_x = rel_pos.dot(player_right)
		var local_y = rel_pos.dot(player_forward) # Forward is Y on radar usually
		
		# Normalized -1 to 1
		var norm_x = local_x / radar_range
		var norm_y = local_y / radar_range
		
		# Map to UI Size (e.g. 200x200)
		var ui_pos = Vector2(norm_x, -norm_y) * (size / 2.0) + (size / 2.0)
		
		# Clamp to circle
		var center = size / 2.0
		if ui_pos.distance_to(center) > (size.x / 2.0):
			ui_pos = center + (ui_pos - center).normalized() * (size.x / 2.0)
			
		_draw_blip(t, ui_pos)

func _draw_blip(target: Node3D, pos: Vector2):
	if not _active_blips.has(target):
		var blip = _get_blip_from_pool()
		add_child(blip)
		_active_blips[target] = blip
	
	var blip = _active_blips[target]
	blip.visible = true
	blip.position = pos
	# Color based on friend/foe?

func _get_blip_from_pool() -> Control:
	# Simplified pool
	if blip_scene:
		return blip_scene.instantiate()
	# Fallback square
	var c = ColorRect.new()
	c.color = Color.RED
	c.custom_minimum_size = Vector2(4, 4)
	return c
