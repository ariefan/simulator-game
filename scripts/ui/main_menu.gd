extends Control

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Check if save file exists to enable/disable continue button
	if SaveManager and SaveManager.has_save_file():
		continue_button.disabled = false
	else:
		continue_button.disabled = true


func _on_new_game_pressed() -> void:
	print("[MainMenu] Starting new game")

	# Initialize new game state
	if GameManager:
		GameManager.new_game()

	# Load the game scene (field)
	get_tree().change_scene_to_file("res://scenes/world/field.tscn")


func _on_continue_pressed() -> void:
	print("[MainMenu] Continuing game")

	# Load saved game
	if SaveManager and SaveManager.load_game():
		# Load the saved scene
		var scene_path = GameManager.current_scene
		get_tree().change_scene_to_file(scene_path)
	else:
		print("[MainMenu] Failed to load save file")


func _on_quit_pressed() -> void:
	print("[MainMenu] Quitting game")
	get_tree().quit()
