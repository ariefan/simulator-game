extends Area2D

@export var target_scene: String = ""
@export var spawn_position: Vector2 = Vector2(540, 960)

@onready var label: Label = $Label


func _ready() -> void:
	# Connect signals
	body_entered.connect(_on_body_entered)

	# Set up collision
	collision_layer = 0
	collision_mask = 2  # Detect player

	# Show interaction label
	if label:
		label.text = "[E] Enter"


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Show prompt or auto-trigger
		# For now, we'll auto-trigger when player walks into portal
		_transition_scene()


func _transition_scene() -> void:
	if target_scene == "":
		print("[Portal] No target scene set!")
		return

	# Save player position for the new scene
	if GameManager:
		GameManager.current_scene = target_scene
		GameManager.player_position = spawn_position

	# Auto-save before transition
	if SaveManager:
		SaveManager.auto_save()

	# Change scene
	get_tree().change_scene_to_file(target_scene)
