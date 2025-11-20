extends Node

const SAVE_FILE_PATH: String = "user://savegame.json"

signal save_completed()
signal load_completed()


func _ready() -> void:
	print("[SaveManager] Initialized")


# Save the current game state
func save_game() -> void:
	var save_data = GameManager.get_save_data()

	# Convert to JSON
	var json_string = JSON.stringify(save_data, "\t")

	# Write to file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("[SaveManager] Game saved to: ", SAVE_FILE_PATH)
		save_completed.emit()
	else:
		print("[SaveManager] ERROR: Could not open save file for writing!")


# Load the saved game state
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("[SaveManager] No save file found")
		return false

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		print("[SaveManager] ERROR: Could not open save file for reading!")
		return false

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		print("[SaveManager] ERROR: Could not parse save file JSON!")
		return false

	var save_data = json.data
	GameManager.load_save_data(save_data)

	print("[SaveManager] Game loaded from: ", SAVE_FILE_PATH)
	load_completed.emit()
	return true


# Check if a save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)


# Delete the save file
func delete_save_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		print("[SaveManager] Save file deleted")


# Auto-save functionality
func auto_save() -> void:
	save_game()
	print("[SaveManager] Auto-saved")
