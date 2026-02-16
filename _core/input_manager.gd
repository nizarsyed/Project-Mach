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
	_ensure_default_actions()
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
	var raw_pitch = _get_axis_safe("pitch_down", "pitch_up")
	var raw_roll = _get_axis_safe("roll_left", "roll_right")
	var raw_yaw = _get_axis_safe("yaw_left", "yaw_right")
	
	pitch_input = _apply_curve(raw_pitch, pitch_curve_power)
	roll_input = _apply_curve(raw_roll, roll_curve_power)
	yaw_input = _apply_curve(raw_yaw, yaw_curve_power)
	
	if _is_action_pressed_safe("throttle_up"):
		throttle_input = move_toward(throttle_input, 1.0, 0.5 * get_process_delta_time())
	elif _is_action_pressed_safe("throttle_down"):
		throttle_input = move_toward(throttle_input, 0.0, 0.5 * get_process_delta_time())
		
	fire_primary = _is_action_pressed_safe("fire_gun")
	fire_secondary = _is_action_pressed_safe("fire_missile")

func _process_touch_input():
	var raw_pitch = _virtual_right_stick.y
	var raw_roll = _virtual_right_stick.x
	var raw_yaw = _virtual_left_stick.x
	throttle_input = clamp((_virtual_left_stick.y + 1.0) / 2.0, 0.0, 1.0)
	
	pitch_input = _apply_curve(raw_pitch, pitch_curve_power)
	roll_input = _apply_curve(raw_roll, roll_curve_power)
	yaw_input = _apply_curve(raw_yaw, yaw_curve_power)
	fire_primary = false
	fire_secondary = false

func _apply_curve(val: float, power: float) -> float:
	return sign(val) * pow(abs(val), power)

func _is_action_pressed_safe(action: StringName) -> bool:
	if not InputMap.has_action(action):
		return false
	return Input.is_action_pressed(action)

func _get_axis_safe(negative_action: StringName, positive_action: StringName) -> float:
	var has_negative = InputMap.has_action(negative_action)
	var has_positive = InputMap.has_action(positive_action)
	if not has_negative and not has_positive:
		return 0.0
	if has_negative and has_positive:
		return Input.get_axis(negative_action, positive_action)
	var axis = 0.0
	if _is_action_pressed_safe(positive_action):
		axis += 1.0
	if _is_action_pressed_safe(negative_action):
		axis -= 1.0
	return axis

func _ensure_default_actions():
	_ensure_key_action("pitch_up", KEY_W)
	_ensure_key_action("pitch_down", KEY_S)
	_ensure_key_action("roll_left", KEY_A)
	_ensure_key_action("roll_right", KEY_D)
	_ensure_key_action("yaw_left", KEY_Q)
	_ensure_key_action("yaw_right", KEY_E)
	_ensure_key_action("throttle_up", KEY_SHIFT)
	_ensure_key_action("throttle_down", KEY_CTRL)
	_ensure_key_action("fire_gun", KEY_SPACE)
	_ensure_key_action("fire_missile", KEY_ALT)

func _ensure_key_action(action: StringName, keycode: Key):
	if not InputMap.has_action(action):
		InputMap.add_action(action)

	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return

	var key_event = InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action, key_event)

func update_virtual_left(vec: Vector2):
	_virtual_left_stick = vec

func update_virtual_right(vec: Vector2):
	_virtual_right_stick = vec
