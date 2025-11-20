extends CanvasLayer

@onready var quest_panel: Panel = $QuestPanel
@onready var quest_container: VBoxContainer = $QuestPanel/MarginContainer/ScrollContainer/QuestContainer
@onready var no_quests_label: Label = $QuestPanel/MarginContainer/ScrollContainer/QuestContainer/NoQuestsLabel

var is_visible: bool = false


func _ready() -> void:
	# Connect to GameManager signals
	if GameManager:
		GameManager.quest_updated.connect(_on_quest_updated)

	# Hide initially
	quest_panel.visible = false

	# Initial update
	_update_quest_display()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		toggle_visibility()


func toggle_visibility() -> void:
	is_visible = !is_visible
	quest_panel.visible = is_visible
	_update_quest_display()


func _on_quest_updated(_quest_id: String) -> void:
	if is_visible:
		_update_quest_display()


func _update_quest_display() -> void:
	# Clear existing quest items (except the no quests label)
	for child in quest_container.get_children():
		if child != no_quests_label:
			child.queue_free()

	# Get quest definitions
	var quest_defs = load("res://data/quests/quest_definitions.gd").new()

	# Check if there are any active quests
	var has_quests = false

	for quest_id in GameManager.quests:
		var quest_state = GameManager.quests[quest_id]
		if quest_state["state"] == "IN_PROGRESS":
			has_quests = true
			var quest_def = quest_defs.get_quest(quest_id)

			# Create quest entry
			var quest_entry = VBoxContainer.new()
			quest_entry.add_theme_constant_override("separation", 5)

			# Title
			var title_label = Label.new()
			title_label.text = quest_def.title
			var title_settings = LabelSettings.new()
			title_settings.font_size = 20
			title_settings.font_color = Color(1, 0.9, 0.4)
			title_label.label_settings = title_settings
			quest_entry.add_child(title_label)

			# Description
			var desc_label = Label.new()
			desc_label.text = quest_def.description
			desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			quest_entry.add_child(desc_label)

			# Objectives
			for objective in quest_def.objectives:
				var obj_label = Label.new()
				var current = GameManager.get_quest_progress(quest_id, objective.key)
				var target = objective.target
				obj_label.text = "  - %s: %d / %d" % [objective.description, current, target]
				quest_entry.add_child(obj_label)

			# Add separator
			var separator = HSeparator.new()
			quest_entry.add_child(separator)

			quest_container.add_child(quest_entry)

	# Show/hide "no quests" label
	no_quests_label.visible = !has_quests
