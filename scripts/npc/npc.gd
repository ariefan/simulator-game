extends CharacterBody2D

# NPC configuration
@export var npc_id: String = "villager"
@export var npc_name: String = "Villager"
@export var quest_giver: bool = false
@export var quest_id: String = ""

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_label: Label = $InteractionLabel

# Dialogue data
var dialogue_data = null
var quest_data = null


func _ready() -> void:
	# Set up collision layers
	collision_layer = 8  # NPC layer
	collision_mask = 1  # Collide with World

	# Load dialogue data
	dialogue_data = load("res://data/dialogues/npc_dialogues.gd").new()

	# Load quest data if quest giver
	if quest_giver and quest_id != "":
		quest_data = load("res://data/quests/quest_definitions.gd").new()

	# Hide interaction label initially
	interaction_label.visible = false


func _physics_process(_delta: float) -> void:
	# Check if player is nearby to show interaction prompt
	_update_interaction_prompt()


func _update_interaction_prompt() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		interaction_label.visible = distance < 80.0 and not DialogueManager.is_active()
	else:
		interaction_label.visible = false


func interact() -> void:
	if DialogueManager.is_active():
		return

	var dialogue: Array = []

	# If quest giver, provide quest-specific dialogue
	if quest_giver and quest_id != "":
		dialogue = _get_quest_dialogue()
	else:
		# Regular NPC dialogue
		dialogue = dialogue_data.get_dialogue(npc_id, "default")

	# Start dialogue
	if dialogue.size() > 0:
		DialogueManager.start_dialogue(npc_id, dialogue)

		# If quest giver and dialogue finished, handle quest logic
		if quest_giver and quest_id != "":
			await DialogueManager.dialogue_ended
			_handle_quest_logic()


func _get_quest_dialogue() -> Array:
	if not quest_data:
		return dialogue_data.get_dialogue(npc_id, "default")

	var quest_def = quest_data.get_quest(quest_id)
	if not quest_def:
		return dialogue_data.get_dialogue(npc_id, "default")

	# Check quest state
	if GameManager.is_quest_completed(quest_id):
		# Quest already completed
		return dialogue_data.get_dialogue(npc_id, "default")
	elif GameManager.is_quest_active(quest_id):
		# Quest in progress - check if ready to complete
		if _is_quest_ready_to_complete():
			return quest_def.dialogue_complete
		else:
			return quest_def.dialogue_in_progress
	else:
		# Quest not started
		return quest_def.dialogue_start


func _is_quest_ready_to_complete() -> bool:
	if not quest_data:
		return false

	var quest_def = quest_data.get_quest(quest_id)
	if not quest_def:
		return false

	# Check if all objectives are met
	for objective in quest_def.objectives:
		var current = GameManager.get_quest_progress(quest_id, objective.key)
		if current < objective.target:
			return false

	return true


func _handle_quest_logic() -> void:
	if not quest_data:
		return

	var quest_def = quest_data.get_quest(quest_id)
	if not quest_def:
		return

	# Start quest if not started
	if not GameManager.is_quest_active(quest_id) and not GameManager.is_quest_completed(quest_id):
		GameManager.start_quest(quest_id)
		print("[NPC] Quest started: ", quest_id)

	# Complete quest if ready
	elif GameManager.is_quest_active(quest_id) and _is_quest_ready_to_complete():
		_give_quest_rewards(quest_def)
		GameManager.complete_quest(quest_id)
		print("[NPC] Quest completed: ", quest_id)


func _give_quest_rewards(quest_def: Dictionary) -> void:
	var rewards = quest_def.get("rewards", {})

	# Give XP
	if rewards.has("xp"):
		GameManager.add_xp(rewards.xp)

	# Give gold
	if rewards.has("gold"):
		GameManager.add_gold(rewards.gold)

	# Give items
	if rewards.has("items"):
		for item_id in rewards.items:
			GameManager.add_item(item_id, 1)

	print("[NPC] Rewards given: XP=%d, Gold=%d, Items=%s" % [
		rewards.get("xp", 0),
		rewards.get("gold", 0),
		str(rewards.get("items", []))
	])
