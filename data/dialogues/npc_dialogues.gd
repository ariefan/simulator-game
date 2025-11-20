extends Node

# NPC dialogue database

var dialogues: Dictionary = {
	"elder": {
		"default": [
			{"speaker": "Elder", "text": "Welcome to our village, traveler."},
			{"speaker": "Elder", "text": "If you need work, I may have tasks for you."}
		],
		"greeting": [
			{"speaker": "Elder", "text": "Ah, hello again! How can I help you?"}
		]
	},
	"merchant": {
		"default": [
			{"speaker": "Merchant", "text": "Welcome to my shop! I have the finest goods!"},
			{"speaker": "Merchant", "text": "Come back anytime!"}
		]
	},
	"villager": {
		"default": [
			{"speaker": "Villager", "text": "Nice day, isn't it?"},
			{"speaker": "Villager", "text": "I heard there are slimes in the field. Be careful!"}
		]
	},
	"house_npc": {
		"default": [
			{"speaker": "Mysterious Figure", "text": "..."},
			{"speaker": "Mysterious Figure", "text": "You shouldn't be here."}
		]
	}
}


# Get dialogue for an NPC
func get_dialogue(npc_id: String, dialogue_type: String = "default") -> Array:
	if dialogues.has(npc_id) and dialogues[npc_id].has(dialogue_type):
		return dialogues[npc_id][dialogue_type]
	elif dialogues.has(npc_id) and dialogues[npc_id].has("default"):
		return dialogues[npc_id]["default"]
	else:
		return [{"speaker": "???", "text": "..."}]
