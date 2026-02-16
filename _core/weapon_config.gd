extends Resource
class_name WeaponConfig

@export_group("Stats")
@export var damage: float = 10.0
@export var fire_rate: float = 0.08
@export var max_range: float = 1500.0
@export var bullet_speed: float = 2000.0

@export_group("Heat")
@export var heat_per_shot: float = 0.02
@export var cooling_rate: float = 0.4

@export_group("Aim Assist")
@export_range(0.0, 10.0) var magnetism_angle_degrees: float = 2.5
@export_range(0.0, 1.0) var magnetism_strength: float = 0.5
