extends CharacterBody2D

# Movement constants
const SPEED: float = 200.0
const ACCELERATION: float = 1500.0
const FRICTION: float = 1200.0

# Attack constants
const ATTACK_RANGE: float = 60.0
const ATTACK_DAMAGE: int = 15
const ATTACK_COOLDOWN: float = 0.5

# State
var can_move: bool = true
var is_attacking: bool = false
var attack_timer: float = 0.0
var facing_direction: Vector2 = Vector2.DOWN

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D

# Input (can come from keyboard or virtual joystick)
var input_vector: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Set up collision layers
	collision_layer = 2  # Player layer
	collision_mask = 1 | 4  # Collide with World and Enemy

	# Set up interaction area
	interaction_area.monitoring = true
	interaction_area.collision_layer = 0
	interaction_area.collision_mask = 8 | 16  # NPC and Items

	# Set up attack area
	attack_area.monitoring = false
	attack_collision.disabled = true

	# Set initial position from GameManager if available
	if GameManager:
		global_position = GameManager.player_position


func _physics_process(delta: float) -> void:
	# Update attack timer
	if attack_timer > 0:
		attack_timer -= delta

	# Handle input and movement
	if can_move and not DialogueManager.is_active():
		_handle_movement_input()
		_apply_movement(delta)
	else:
		_apply_friction(delta)

	move_and_slide()

	# Update player position in GameManager
	if GameManager:
		GameManager.player_position = global_position


func _input(event: InputEvent) -> void:
	# Handle attack input
	if event.is_action_pressed("attack") and can_move and not is_attacking and attack_timer <= 0:
		_perform_attack()

	# Handle interaction input
	if event.is_action_pressed("interact") and can_move:
		_try_interact()


# Movement input from keyboard
func _handle_movement_input() -> void:
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")

	# Normalize for diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		facing_direction = input_vector


# Apply movement with acceleration
func _apply_movement(delta: float) -> void:
	if input_vector.length() > 0:
		velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
	else:
		_apply_friction(delta)


# Apply friction when not moving
func _apply_friction(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)


# Set input vector (used by virtual joystick)
func set_input_vector(vec: Vector2) -> void:
	input_vector = vec
	if vec.length() > 0:
		facing_direction = vec.normalized()


# Perform attack
func _perform_attack() -> void:
	is_attacking = true
	attack_timer = ATTACK_COOLDOWN

	# Position attack area in front of player
	attack_area.position = facing_direction * (ATTACK_RANGE / 2)
	attack_area.rotation = facing_direction.angle()

	# Enable attack collision briefly
	attack_collision.disabled = false
	attack_area.monitoring = true

	# Check for enemies in attack range
	await get_tree().create_timer(0.1).timeout
	var enemies_hit = attack_area.get_overlapping_bodies()
	for enemy in enemies_hit:
		if enemy.has_method("take_damage"):
			enemy.take_damage(ATTACK_DAMAGE)

	# Disable attack area
	attack_collision.disabled = true
	attack_area.monitoring = false

	await get_tree().create_timer(0.2).timeout
	is_attacking = false


# Try to interact with nearby NPCs or objects
func _try_interact() -> void:
	if DialogueManager.is_active():
		DialogueManager.next_line()
		return

	var nearby = interaction_area.get_overlapping_bodies() + interaction_area.get_overlapping_areas()

	for obj in nearby:
		if obj.has_method("interact"):
			obj.interact()
			return


# Take damage from enemies
func take_damage(amount: int) -> void:
	if GameManager:
		GameManager.take_damage(amount)

	# Visual feedback (optional: add hit animation)
	_flash_sprite()


# Visual feedback for taking damage
func _flash_sprite() -> void:
	if sprite:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color.WHITE


# Prevent movement (e.g., during dialogue)
func set_can_move(value: bool) -> void:
	can_move = value
	if not can_move:
		velocity = Vector2.ZERO
