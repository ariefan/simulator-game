extends Node

# Item database - data-driven item definitions
# This makes it easy to add new items without changing code

var items: Dictionary = {
	"health_potion": {
		"id": "health_potion",
		"name": "Health Potion",
		"description": "Restores 30 HP",
		"type": "consumable",
		"heal_amount": 30,
		"icon": "res://assets/sprites/items/potion.png",
		"stackable": true
	},
	"slime_goo": {
		"id": "slime_goo",
		"name": "Slime Goo",
		"description": "A sticky substance dropped by slimes. Used in alchemy.",
		"type": "material",
		"icon": "res://assets/sprites/items/slime_goo.png",
		"stackable": true
	},
	"gold_coin": {
		"id": "gold_coin",
		"name": "Gold Coin",
		"description": "Currency used for trading.",
		"type": "currency",
		"icon": "res://assets/sprites/items/coin.png",
		"stackable": true
	},
	"rusty_sword": {
		"id": "rusty_sword",
		"name": "Rusty Sword",
		"description": "An old sword. Better than nothing.",
		"type": "weapon",
		"attack_bonus": 5,
		"icon": "res://assets/sprites/items/sword.png",
		"stackable": false
	},
	"leather_armor": {
		"id": "leather_armor",
		"name": "Leather Armor",
		"description": "Basic armor made of leather.",
		"type": "armor",
		"defense_bonus": 3,
		"icon": "res://assets/sprites/items/armor.png",
		"stackable": false
	},
	"quest_reward_crystal": {
		"id": "quest_reward_crystal",
		"name": "Magic Crystal",
		"description": "A glowing crystal. Proof of your heroism!",
		"type": "quest_item",
		"icon": "res://assets/sprites/items/crystal.png",
		"stackable": false
	}
}


# Get item data by ID
func get_item(item_id: String) -> Dictionary:
	if items.has(item_id):
		return items[item_id]
	else:
		print("[ItemDefinitions] WARNING: Item not found: ", item_id)
		return {}


# Get all items (for debugging/testing)
func get_all_items() -> Dictionary:
	return items
