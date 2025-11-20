extends CanvasLayer

@onready var inventory_panel: Panel = $InventoryPanel
@onready var item_list: ItemList = $InventoryPanel/MarginContainer/VBoxContainer/ItemList
@onready var use_button: Button = $InventoryPanel/MarginContainer/VBoxContainer/ButtonContainer/UseButton
@onready var close_button: Button = $InventoryPanel/MarginContainer/VBoxContainer/ButtonContainer/CloseButton

var is_visible: bool = false
var item_definitions = null


func _ready() -> void:
	# Load item definitions
	item_definitions = load("res://data/items/item_definitions.gd").new()

	# Connect to GameManager signals
	if GameManager:
		GameManager.inventory_changed.connect(_on_inventory_changed)

	# Connect button signals
	use_button.pressed.connect(_on_use_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	item_list.item_selected.connect(_on_item_selected)

	# Hide initially
	inventory_panel.visible = false

	# Initial update
	_update_inventory_display()


func _input(event: InputEvent) -> void:
	# Toggle with 'I' key (menu action)
	if event.is_action_pressed("menu") and not DialogueManager.is_active():
		# Note: This will conflict with quest log if both use same key
		# In full implementation, would have a unified menu system
		pass


func toggle_visibility() -> void:
	is_visible = !is_visible
	inventory_panel.visible = is_visible
	if is_visible:
		_update_inventory_display()


func show_inventory() -> void:
	is_visible = true
	inventory_panel.visible = true
	_update_inventory_display()


func hide_inventory() -> void:
	is_visible = false
	inventory_panel.visible = false


func _on_inventory_changed() -> void:
	if is_visible:
		_update_inventory_display()


func _update_inventory_display() -> void:
	item_list.clear()

	for inv_item in GameManager.inventory:
		var item_data = item_definitions.get_item(inv_item["id"])
		if item_data:
			var display_text = "%s x%d" % [item_data.name, inv_item["quantity"]]
			item_list.add_item(display_text)
			item_list.set_item_metadata(item_list.get_item_count() - 1, inv_item["id"])


func _on_item_selected(_index: int) -> void:
	# Enable use button when item is selected
	use_button.disabled = false


func _on_use_button_pressed() -> void:
	var selected_indices = item_list.get_selected_items()
	if selected_indices.size() > 0:
		var item_id = item_list.get_item_metadata(selected_indices[0])
		var item_data = item_definitions.get_item(item_id)

		# Only allow using consumables
		if item_data and item_data.type == "consumable":
			GameManager.use_item(item_id)
			_update_inventory_display()
		else:
			print("[InventoryUI] Cannot use this item")


func _on_close_button_pressed() -> void:
	hide_inventory()
