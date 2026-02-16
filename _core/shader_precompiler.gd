extends Node
class_name ShaderPrecompiler

signal compilation_finished

@export var materials_to_warm: Array[Material]
@export var scenes_to_warm: Array[PackedScene]

func _ready():
	# Run deferred to let the engine initialize
	call_deferred("_start_compilation")

func _start_compilation():
	print("ShaderPrecompiler: Starting warmup...")
	
	# 1. create a temporary viewport or just use the main scene but hidden
	# For simplicity, we spawn them far away
	var root = Node3D.new()
	add_child(root)
	root.global_position = Vector3(0, -9999, 0)
	
	# Warm Materials
	for mat in materials_to_warm:
		var mesh = MeshInstance3D.new()
		mesh.mesh = BoxMesh.new() # Simple mesh
		mesh.material_override = mat
		root.add_child(mesh)
	
	# Warm Scenes (Particles, etc)
	for scn in scenes_to_warm:
		var node = scn.instantiate()
		root.add_child(node)
		if node is GPUParticles3D:
			node.emitting = true
			
	# Wait for 2 frames to ensure they are submitted to GPU
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("ShaderPrecompiler: Dynamic compilation done.")
	root.queue_free()
	emit_signal("compilation_finished")
