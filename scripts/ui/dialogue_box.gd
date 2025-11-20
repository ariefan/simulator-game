extends CanvasLayer

@onready var dialogue_panel: Panel = $DialoguePanel
@onready var speaker_label: Label = $DialoguePanel/MarginContainer/VBoxContainer/SpeakerLabel
@onready var dialogue_label: Label = $DialoguePanel/MarginContainer/VBoxContainer/DialogueLabel
@onready var continue_label: Label = $DialoguePanel/MarginContainer/VBoxContainer/ContinueLabel


func _ready() -> void:
	# Connect to DialogueManager signals
	if DialogueManager:
		DialogueManager.dialogue_started.connect(_on_dialogue_started)
		DialogueManager.dialogue_line_displayed.connect(_on_dialogue_line_displayed)
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

	# Hide dialogue box initially
	dialogue_panel.visible = false


func _on_dialogue_started(_npc_id: String) -> void:
	dialogue_panel.visible = true


func _on_dialogue_line_displayed(text: String, speaker: String) -> void:
	speaker_label.text = speaker
	dialogue_label.text = text
	continue_label.visible = true


func _on_dialogue_ended() -> void:
	dialogue_panel.visible = false
	speaker_label.text = ""
	dialogue_label.text = ""
