extends Node

# Signals for UI updates
signal health_changed(new_health: int, max_health: int)
signal xp_changed(current_xp: int, xp_to_next_level: int)
signal level_changed(new_level: int)
signal inventory_changed()
signal quest_updated(quest_id: String)
signal gold_changed(new_gold: int)

# Player Stats
var player_max_health: int = 100
var player_health: int = 100
var player_level: int = 1
var player_xp: int = 0
var player_attack: int = 10
var player_defense: int = 5
var player_gold: int = 0

# XP required for each level (index = level, value = XP needed to reach next level)
var xp_thresholds: Array[int] = [0, 100, 250, 450, 700, 1000]

# Inventory - Array of item dictionaries
var inventory: Array = []
const MAX_INVENTORY_SIZE: int = 20

# Quest state - Dictionary of quest_id -> quest state
var quests: Dictionary = {}

# Player position for save/load
var player_position: Vector2 = Vector2.ZERO
var current_scene: String = "res://scenes/world/field.tscn"

# Interactable reference (for NPC interactions)
var current_interactable: Node = null


func _ready() -> void:
	print("[GameManager] Initialized")


# === PLAYER STATS ===

func take_damage(amount: int) -> void:
	var actual_damage = max(1, amount - player_defense)
	player_health = max(0, player_health - actual_damage)
	health_changed.emit(player_health, player_max_health)

	if player_health <= 0:
		_handle_player_death()


func heal(amount: int) -> void:
	player_health = min(player_max_health, player_health + amount)
	health_changed.emit(player_health, player_max_health)


func add_xp(amount: int) -> void:
	player_xp += amount
	xp_changed.emit(player_xp, _get_xp_for_next_level())

	# Check for level up
	while player_level < xp_thresholds.size() and player_xp >= xp_thresholds[player_level]:
		_level_up()


func add_gold(amount: int) -> void:
	player_gold += amount
	gold_changed.emit(player_gold)


func _get_xp_for_next_level() -> int:
	if player_level < xp_thresholds.size():
		return xp_thresholds[player_level]
	return 9999  # Max level reached


func _level_up() -> void:
	player_level += 1
	player_max_health += 20
	player_health = player_max_health  # Full heal on level up
	player_attack += 3
	player_defense += 2

	level_changed.emit(player_level)
	health_changed.emit(player_health, player_max_health)
	print("[GameManager] Level up! Now level ", player_level)


func _handle_player_death() -> void:
	print("[GameManager] Player died!")
	# Simple death handling: reload from last save or restart
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# === INVENTORY SYSTEM ===

func add_item(item_id: String, quantity: int = 1) -> bool:
	# Check if item already exists in inventory (for stackable items)
	for inv_item in inventory:
		if inv_item["id"] == item_id:
			inv_item["quantity"] += quantity
			inventory_changed.emit()
			return true

	# Add new item if space available
	if inventory.size() < MAX_INVENTORY_SIZE:
		inventory.append({
			"id": item_id,
			"quantity": quantity
		})
		inventory_changed.emit()
		return true

	print("[GameManager] Inventory full!")
	return false


func remove_item(item_id: String, quantity: int = 1) -> bool:
	for i in range(inventory.size()):
		if inventory[i]["id"] == item_id:
			inventory[i]["quantity"] -= quantity
			if inventory[i]["quantity"] <= 0:
				inventory.remove_at(i)
			inventory_changed.emit()
			return true
	return false


func has_item(item_id: String, quantity: int = 1) -> bool:
	for inv_item in inventory:
		if inv_item["id"] == item_id and inv_item["quantity"] >= quantity:
			return true
	return false


func use_item(item_id: String) -> void:
	if not has_item(item_id):
		return

	# Get item definition from item database
	var item_data = load("res://data/items/item_definitions.gd").new().get_item(item_id)
	if not item_data:
		return

	# Apply item effect
	match item_data.type:
		"consumable":
			if item_data.has("heal_amount"):
				heal(item_data.heal_amount)
				print("[GameManager] Used ", item_data.name, " - Healed ", item_data.heal_amount, " HP")
			remove_item(item_id, 1)
		_:
			print("[GameManager] Cannot use item: ", item_data.name)


# === QUEST SYSTEM ===

func start_quest(quest_id: String) -> void:
	if quests.has(quest_id):
		return  # Already started

	quests[quest_id] = {
		"state": "IN_PROGRESS",
		"progress": {},
		"completed": false
	}
	quest_updated.emit(quest_id)
	print("[GameManager] Quest started: ", quest_id)


func update_quest_progress(quest_id: String, progress_key: String, value: int) -> void:
	if not quests.has(quest_id):
		return

	if quests[quest_id]["state"] != "IN_PROGRESS":
		return

	quests[quest_id]["progress"][progress_key] = value
	quest_updated.emit(quest_id)

	# Check if quest is complete
	_check_quest_completion(quest_id)


func complete_quest(quest_id: String) -> void:
	if not quests.has(quest_id):
		return

	quests[quest_id]["state"] = "COMPLETED"
	quests[quest_id]["completed"] = true
	quest_updated.emit(quest_id)
	print("[GameManager] Quest completed: ", quest_id)


func is_quest_active(quest_id: String) -> bool:
	return quests.has(quest_id) and quests[quest_id]["state"] == "IN_PROGRESS"


func is_quest_completed(quest_id: String) -> bool:
	return quests.has(quest_id) and quests[quest_id]["completed"]


func get_quest_progress(quest_id: String, progress_key: String) -> int:
	if quests.has(quest_id) and quests[quest_id]["progress"].has(progress_key):
		return quests[quest_id]["progress"][progress_key]
	return 0


func _check_quest_completion(quest_id: String) -> void:
	# Load quest definition to check completion criteria
	var quest_def = load("res://data/quests/quest_definitions.gd").new().get_quest(quest_id)
	if not quest_def:
		return

	# Check if all objectives are met
	var all_complete = true
	for objective in quest_def.objectives:
		var current = get_quest_progress(quest_id, objective.key)
		if current < objective.target:
			all_complete = false
			break

	if all_complete:
		complete_quest(quest_id)


# === NEW GAME ===

func new_game() -> void:
	print("[GameManager] Starting new game")

	# Reset all stats
	player_max_health = 100
	player_health = 100
	player_level = 1
	player_xp = 0
	player_attack = 10
	player_defense = 5
	player_gold = 0

	inventory.clear()
	quests.clear()

	# Add starting items
	add_item("health_potion", 3)
	add_item("slime_goo", 1)

	# Starting position
	current_scene = "res://scenes/world/field.tscn"
	player_position = Vector2(540, 960)  # Center of screen

	# Emit initial signals
	health_changed.emit(player_health, player_max_health)
	xp_changed.emit(player_xp, _get_xp_for_next_level())
	level_changed.emit(player_level)
	inventory_changed.emit()
	gold_changed.emit(player_gold)


# === SAVE DATA ===

func get_save_data() -> Dictionary:
	return {
		"player_health": player_health,
		"player_max_health": player_max_health,
		"player_level": player_level,
		"player_xp": player_xp,
		"player_attack": player_attack,
		"player_defense": player_defense,
		"player_gold": player_gold,
		"inventory": inventory.duplicate(true),
		"quests": quests.duplicate(true),
		"player_position": {"x": player_position.x, "y": player_position.y},
		"current_scene": current_scene
	}


func load_save_data(data: Dictionary) -> void:
	player_health = data.get("player_health", 100)
	player_max_health = data.get("player_max_health", 100)
	player_level = data.get("player_level", 1)
	player_xp = data.get("player_xp", 0)
	player_attack = data.get("player_attack", 10)
	player_defense = data.get("player_defense", 5)
	player_gold = data.get("player_gold", 0)
	inventory = data.get("inventory", [])
	quests = data.get("quests", {})

	var pos_data = data.get("player_position", {"x": 540, "y": 960})
	player_position = Vector2(pos_data.x, pos_data.y)
	current_scene = data.get("current_scene", "res://scenes/world/field.tscn")

	# Emit all signals to update UI
	health_changed.emit(player_health, player_max_health)
	xp_changed.emit(player_xp, _get_xp_for_next_level())
	level_changed.emit(player_level)
	inventory_changed.emit()
	gold_changed.emit(player_gold)

	print("[GameManager] Save data loaded")
