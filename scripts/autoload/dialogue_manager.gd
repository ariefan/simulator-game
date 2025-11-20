extends Node

signal dialogue_started(npc_id: String)
signal dialogue_line_displayed(text: String, speaker_name: String)
signal dialogue_ended()

var is_dialogue_active: bool = false
var current_dialogue: Array = []
var current_line_index: int = 0
var current_npc_id: String = ""


func _ready() -> void:
	print("[DialogueManager] Initialized")


# Start a dialogue sequence
func start_dialogue(npc_id: String, dialogue_lines: Array) -> void:
	if is_dialogue_active:
		return

	current_npc_id = npc_id
	current_dialogue = dialogue_lines
	current_line_index = 0
	is_dialogue_active = true

	dialogue_started.emit(npc_id)
	_show_next_line()


# Show the next line of dialogue
func next_line() -> void:
	if not is_dialogue_active:
		return

	current_line_index += 1
	if current_line_index >= current_dialogue.size():
		end_dialogue()
	else:
		_show_next_line()


# Display current dialogue line
func _show_next_line() -> void:
	if current_line_index < current_dialogue.size():
		var line_data = current_dialogue[current_line_index]
		var speaker = line_data.get("speaker", "???")
		var text = line_data.get("text", "")
		dialogue_line_displayed.emit(text, speaker)


# End the current dialogue
func end_dialogue() -> void:
	if not is_dialogue_active:
		return

	is_dialogue_active = false
	current_dialogue.clear()
	current_line_index = 0
	current_npc_id = ""

	dialogue_ended.emit()


# Check if dialogue is currently active
func is_active() -> bool:
	return is_dialogue_active
