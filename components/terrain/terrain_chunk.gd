extends Node3D
class_name TerrainChunk

# 512m x 512m chunk
const CHUNK_SIZE = 512.0

@export var mesh_high: MeshInstance3D
@export var mesh_low: MeshInstance3D
@export var collider: StaticBody3D

var _fading: bool = false

func set_lod(level: int):
	# Level 0: High (Collision ON)
	# Level 1: Low (Collision OFF)
	# Level 2: Hidden
	
	match level:
		0:
			if mesh_high: mesh_high.visible = true
			if mesh_low: mesh_low.visible = false
			if collider: collider.process_mode = Node.PROCESS_MODE_INHERIT
		1:
			if mesh_high: mesh_high.visible = false
			if mesh_low: mesh_low.visible = true
			if collider: collider.process_mode = Node.PROCESS_MODE_DISABLED
		2:
			visible = false
