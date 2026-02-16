extends RigidBody3D
class_name Flare

@export var lifetime: float = 3.0
@export var heat_intensity: float = 2.0

var _timer: float = 0.0

func _ready():
	add_to_group("Flares")
	set_process(true)

func _process(delta):
	_timer += delta
	if _timer > lifetime:
		queue_free()

func get_heat_intensity() -> float:
	return heat_intensity * (1.0 - (_timer / lifetime))
