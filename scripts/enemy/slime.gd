extends "res://scripts/enemy/enemy.gd"

# Slime-specific configuration


func _ready() -> void:
	super._ready()

	# Slime stats
	max_health = 30
	health = 30
	damage = 8
	move_speed = 60.0
	xp_reward = 25
	enemy_type = "slime"

	# Slime loot
	loot_table = [
		{"item_id": "slime_goo", "chance": 0.8},
		{"item_id": "gold_coin", "chance": 0.2}
	]
