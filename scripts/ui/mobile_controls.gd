extends CanvasLayer

# Virtual joystick
@onready var joystick_base: Control = $VirtualJoystick/JoystickBase
@onready var joystick_knob: Control = $VirtualJoystick/JoystickKnob

# Action buttons
@onready var attack_button: Button = $ActionButtons/AttackButton
@onready var interact_button: Button = $ActionButtons/InteractButton
@onready var menu_button: Button = $ActionButtons/MenuButton

# Joystick settings
const JOYSTICK_RADIUS: float = 80.0
const DEAD_ZONE: float = 0.2

var joystick_vector: Vector2 = Vector2.ZERO
var is_touching_joystick: bool = false
var joystick_touch_index: int = -1

# Player reference
var player: CharacterBody2D = null


func _ready() -> void:
	# Connect button signals
	attack_button.pressed.connect(_on_attack_pressed)
	interact_button.pressed.connect(_on_interact_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

	# Set up joystick
	joystick_knob.position = Vector2.ZERO


func _process(_delta: float) -> void:
	# Send joystick input to player
	if player and player.has_method("set_input_vector"):
		player.set_input_vector(joystick_vector)


func set_player(p: CharacterBody2D) -> void:
	player = p


func _input(event: InputEvent) -> void:
	# Handle touch input for virtual joystick
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(event: InputEventScreenTouch) -> void:
	var touch_pos = event.position

	# Check if touch is on joystick area
	var joystick_global_pos = joystick_base.global_position + joystick_base.size / 2
	var distance = touch_pos.distance_to(joystick_global_pos)

	if event.pressed:
		# Start joystick control if touching joystick area
		if distance < JOYSTICK_RADIUS * 1.5:
			is_touching_joystick = true
			joystick_touch_index = event.index
	else:
		# Release joystick
		if event.index == joystick_touch_index:
			is_touching_joystick = false
			joystick_touch_index = -1
			joystick_knob.position = Vector2.ZERO
			joystick_vector = Vector2.ZERO


func _handle_drag(event: InputEventScreenDrag) -> void:
	if is_touching_joystick and event.index == joystick_touch_index:
		var joystick_center = joystick_base.global_position + joystick_base.size / 2
		var offset = event.position - joystick_center

		# Clamp to joystick radius
		if offset.length() > JOYSTICK_RADIUS:
			offset = offset.normalized() * JOYSTICK_RADIUS

		joystick_knob.position = offset

		# Calculate joystick vector
		var normalized_offset = offset / JOYSTICK_RADIUS
		if normalized_offset.length() < DEAD_ZONE:
			joystick_vector = Vector2.ZERO
		else:
			joystick_vector = normalized_offset.normalized()


func _on_attack_pressed() -> void:
	# Simulate attack input
	var action_event = InputEventAction.new()
	action_event.action = "attack"
	action_event.pressed = true
	Input.parse_input_event(action_event)


func _on_interact_pressed() -> void:
	# Simulate interact input
	var action_event = InputEventAction.new()
	action_event.action = "interact"
	action_event.pressed = true
	Input.parse_input_event(action_event)


func _on_menu_pressed() -> void:
	# Simulate menu input
	var action_event = InputEventAction.new()
	action_event.action = "menu"
	action_event.pressed = true
	Input.parse_input_event(action_event)
