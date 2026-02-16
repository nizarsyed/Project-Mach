extends Node3D
class_name TerrainStreamer

@export var target: Node3D # Usually the Player Jet
@export var chunk_scene: PackedScene
@export var render_distance: int = 4 # Chunks radius (e.g. 4 * 512m = 2km)
@export var update_frequency: float = 0.5 # Seconds

var _loaded_chunks = {} # Vector2(x, z) -> TerrainChunk
var _timer: float = 0.0
var _last_chunk_pos: Vector2i = Vector2i(9999, 9999)

func _ready():
	# If no target set, try to find player
	if not target:
		target = get_tree().get_first_node_in_group("Player")

func _process(delta):
	if not target: return
	
	_timer -= delta
	if _timer <= 0:
		_timer = update_frequency
		_update_chunks()

func _update_chunks():
	var player_pos = target.global_position
	# Calculate which chunk coordinates the player is in
	var center_chunk_x = floori(player_pos.x / TerrainChunk.CHUNK_SIZE)
	var center_chunk_z = floori(player_pos.z / TerrainChunk.CHUNK_SIZE)
	var current_chunk_pos = Vector2i(center_chunk_x, center_chunk_z)
	
	# Only update if moved to a new chunk (optimization)
	if current_chunk_pos == _last_chunk_pos:
		return
	_last_chunk_pos = current_chunk_pos
	
	# 1. Identify chunks that should be loaded
	var needed_chunks = []
	for x in range(center_chunk_x - render_distance, center_chunk_x + render_distance + 1):
		for z in range(center_chunk_z - render_distance, center_chunk_z + render_distance + 1):
			needed_chunks.append(Vector2i(x, z))
	
	# 2. Unload chunks that are too far
	var to_remove = []
	for coords in _loaded_chunks:
		# If coords not in needed_chunks (Simple distance check is faster than array search?)
		if abs(coords.x - center_chunk_x) > render_distance or abs(coords.y - center_chunk_z) > render_distance:
			to_remove.append(coords)
			
	for coords in to_remove:
		var chunk = _loaded_chunks[coords]
		chunk.queue_free()
		_loaded_chunks.erase(coords)
	
	# 3. Load or Update LOD for needed chunks
	for coords in needed_chunks:
		if coords in _loaded_chunks:
			_update_chunk_lod(curr_coords_to_world(coords), _loaded_chunks[coords])
		else:
			_load_chunk(coords)

func _load_chunk(coords: Vector2i):
	if not chunk_scene: return
	
	var chunk = chunk_scene.instantiate() as TerrainChunk
	add_child(chunk)
	
	# Position
	var world_x = coords.x * TerrainChunk.CHUNK_SIZE
	var world_z = coords.y * TerrainChunk.CHUNK_SIZE # Vector2i uses .y for Z component logic here
	chunk.global_position = Vector3(world_x, 0, world_z)
	
	_loaded_chunks[coords] = chunk
	_update_chunk_lod(coords, chunk)

func _update_chunk_lod(coords: Vector2i, chunk: TerrainChunk):
	# Simple Manhattan or Chebyshev distance for grid?
	var center_x = _last_chunk_pos.x
	var center_z = _last_chunk_pos.y
	var dist = max(abs(coords.x - center_x), abs(coords.y - center_z))
	
	if dist <= 1:
		chunk.set_lod(0) # High + Collision
	elif dist <= render_distance:
		chunk.set_lod(1) # Low Visuals
	else:
		chunk.set_lod(2) # Hidden (Should be unloaded anyway)

func curr_coords_to_world(coords: Vector2i) -> Vector2i:
	return coords # Helper if we had offset logic
