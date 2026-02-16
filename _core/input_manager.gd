extends Node

signal virtual_stick_active(is_active: bool)

@export var pitch_curve_power: float = 2.0
@export var roll_curve_power: float = 2.0
@export var yaw_curve_power: float = 1.5

var pitch_input: float = 0.0
var roll_input: float = 0.0
var yaw_input: float = 0.0
var throttle_input: float = 0.0
var fire_primary: bool = false
var fire_secondary: bool = false

var _virtual_left_stick: Vector2 = Vector2.ZERO
var _virtual_right_stick: Vector2 = Vector2.ZERO

func _ready():
	if PlatformManager.is_mobile():
		emit_signal("virtual_stick_active", true)

func _process(_delta):
	_gather_input()

func _gather_input():
	if PlatformManager.is_mobile():
		_process_touch_input()
	else:
		_process_desktop_input()
	
	pitch_input = clamp(pitch_input, -1.0, 1.0)
	roll_input = clamp(roll_input, -1.0, 1.0)
	yaw_input = clamp(yaw_input, -1.0, 1.0)
	throttle_input = clamp(throttle_input, 0.0, 1.0)

func _process_desktop_input():
	var raw_pitch = Input.get_axis("pitch_down", "pitch_up")
	var raw_roll = Input.get_axis("roll_left", "roll_right")
	var raw_yaw = Input.get_axis("yaw_left", "yaw_right")
	
	pitch_input = _apply_curve(raw_pitch, pitch_curve_power)
	roll_input = _apply_curve(raw_roll, roll_curve_power)
	yaw_input = _apply_curve(raw_yaw, yaw_curve_power)
	
	if Input.is_action_pressed("throttle_up"):
		throttle_input = move_toward(throttle_input, 1.0, 0.5 * get_process_delta_time())
	elif Input.is_action_pressed("throttle_down"):
		throttle_input = move_toward(throttle_input, 0.0, 0.5 * get_process_delta_time())
		
	fire_primary = Input.is_action_pressed("fire_gun")
	fire_secondary = Input.is_action_pressed("fire_missile")

func _process_touch_input():
	var raw_pitch = _virtual_right_stick.y
	var raw_roll = _virtual_right_stick.x
	var raw_yaw = _virtual_left_stick.x
	throttle_input = clamp((_virtual_left_stick.y + 1.0) / 2.0, 0.0, 1.0)
	
	pitch_input = _apply_curve(raw_pitch, pitch_curve_power)
	roll_input = _apply_curve(raw_roll, roll_curve_power)
	yaw_input = _apply_curve(raw_yaw, yaw_curve_power)

func _apply_curve(val: float, power: float) -> float:
	return sign(val) * pow(abs(val), power)

func update_virtual_left(vec: Vector2):
	_virtual_left_stick = vec

func update_virtual_right(vec: Vector2):
	_virtual_right_stick = vec
