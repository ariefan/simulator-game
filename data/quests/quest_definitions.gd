extends Node

# Quest database - data-driven quest definitions

var quests: Dictionary = {
	"slime_hunter": {
		"id": "slime_hunter",
		"title": "Slime Hunter",
		"description": "The village elder needs help clearing out slimes from the field. Defeat 3 slimes.",
		"giver_npc": "elder",
		"objectives": [
			{
				"key": "slimes_killed",
				"description": "Defeat slimes",
				"target": 3,
				"type": "kill"
			}
		],
		"rewards": {
			"xp": 100,
			"gold": 50,
			"items": ["health_potion", "quest_reward_crystal"]
		},
		"dialogue_start": [
			{"speaker": "Elder", "text": "Greetings, young adventurer! Our village has been plagued by slimes in the field."},
			{"speaker": "Elder", "text": "Would you help us by defeating 3 of them? I'll reward you handsomely!"}
		],
		"dialogue_in_progress": [
			{"speaker": "Elder", "text": "How goes the slime hunting? Still working on it, I see."},
			{"speaker": "Elder", "text": "Come back when you've defeated all 3 slimes!"}
		],
		"dialogue_complete": [
			{"speaker": "Elder", "text": "Excellent work! You've cleared out those pesky slimes!"},
			{"speaker": "Elder", "text": "Here's your reward. The village thanks you!"}
		]
	},
	"explore_house": {
		"id": "explore_house",
		"title": "Explore the House",
		"description": "The elder mentioned an old house nearby. Go check it out.",
		"giver_npc": "elder",
		"objectives": [
			{
				"key": "house_visited",
				"description": "Visit the old house",
				"target": 1,
				"type": "visit"
			}
		],
		"rewards": {
			"xp": 50,
			"gold": 25,
			"items": []
		},
		"dialogue_start": [
			{"speaker": "Elder", "text": "There's an old house to the east. Perhaps you should explore it?"}
		],
		"dialogue_in_progress": [
			{"speaker": "Elder", "text": "Have you visited the old house yet?"}
		],
		"dialogue_complete": [
			{"speaker": "Elder", "text": "Ah, you've been to the old house! Interesting place, isn't it?"}
		]
	}
}


# Get quest data by ID
func get_quest(quest_id: String) -> Dictionary:
	if quests.has(quest_id):
		return quests[quest_id]
	else:
		print("[QuestDefinitions] WARNING: Quest not found: ", quest_id)
		return {}


# Get all quests
func get_all_quests() -> Dictionary:
	return quests
