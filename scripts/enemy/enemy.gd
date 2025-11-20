extends CharacterBody2D

# Enemy stats
@export var max_health: int = 30
@export var health: int = 30
@export var damage: int = 10
@export var move_speed: float = 80.0
@export var detection_range: float = 150.0
@export var attack_range: float = 50.0
@export var xp_reward: int = 25
@export var enemy_type: String = "slime"

# AI state
enum State { IDLE, PATROL, CHASE, ATTACK }
var current_state: State = State.IDLE

# Combat
var attack_cooldown: float = 1.5
var attack_timer: float = 0.0

# Loot
var loot_table: Array = [
	{"item_id": "slime_goo", "chance": 0.7},
	{"item_id": "gold_coin", "chance": 0.3}
]

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

var player: CharacterBody2D = null


func _ready() -> void:
	# Set up collision layers
	collision_layer = 4  # Enemy layer
	collision_mask = 1 | 2  # Collide with World and Player

	# Set up detection area
	var detection_shape = detection_area.get_node("CollisionShape2D")
	if detection_shape and detection_shape.shape is CircleShape2D:
		detection_shape.shape.radius = detection_range

	# Connect area signals
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)


func _physics_process(delta: float) -> void:
	# Update attack timer
	if attack_timer > 0:
		attack_timer -= delta

	# AI behavior
	match current_state:
		State.IDLE:
			_ai_idle(delta)
		State.CHASE:
			_ai_chase(delta)
		State.ATTACK:
			_ai_attack(delta)

	move_and_slide()


func _ai_idle(_delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, move_speed * 2)


func _ai_chase(_delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * move_speed

		# Check if in attack range
		var distance = global_position.distance_to(player.global_position)
		if distance < attack_range:
			current_state = State.ATTACK
	else:
		current_state = State.IDLE


func _ai_attack(_delta: float) -> void:
	velocity = Vector2.ZERO

	if player:
		var distance = global_position.distance_to(player.global_position)

		# If player moved away, chase again
		if distance > attack_range * 1.5:
			current_state = State.CHASE
			return

		# Attack if cooldown is ready
		if attack_timer <= 0:
			_perform_attack()
	else:
		current_state = State.IDLE


func _perform_attack() -> void:
	attack_timer = attack_cooldown

	# Deal damage to player
	if player and player.has_method("take_damage"):
		player.take_damage(damage)
		print("[Enemy] Attacked player for ", damage, " damage")


func take_damage(amount: int) -> void:
	health -= amount
	print("[Enemy] Took ", amount, " damage. HP: ", health)

	# Visual feedback
	_flash_sprite()

	if health <= 0:
		_die()


func _flash_sprite() -> void:
	if sprite:
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):
			sprite.modulate = Color.WHITE


func _die() -> void:
	print("[Enemy] Died")

	# Grant XP to player
	if GameManager:
		GameManager.add_xp(xp_reward)

	# Update quest progress for kill quests
	if GameManager and enemy_type != "":
		GameManager.update_quest_progress("slime_hunter", "slimes_killed",
			GameManager.get_quest_progress("slime_hunter", "slimes_killed") + 1)

	# Drop loot
	_drop_loot()

	# Remove enemy
	queue_free()


func _drop_loot() -> void:
	for loot_entry in loot_table:
		if randf() < loot_entry.chance:
			if GameManager:
				GameManager.add_item(loot_entry.item_id, 1)
				print("[Enemy] Dropped: ", loot_entry.item_id)


func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		if current_state == State.IDLE:
			current_state = State.CHASE


func _on_detection_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		current_state = State.IDLE
