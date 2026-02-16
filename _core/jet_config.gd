extends Resource
class_name JetConfig

@export_group("Flight Stats")
@export var max_speed: float = 800.0 # m/s
@export var mass: float = 12000.0 # kg
@export var lift_coefficient: float = 0.5
@export var drag_coefficient: float = 0.02

@export_group("Maneuverability")
@export var pitch_speed: float = 2.0 # Rad/s
@export var roll_speed: float = 4.0
@export var yaw_speed: float = 1.0

@export var acceleration_curve: Curve 
@export var turn_authority_curve: Curve
