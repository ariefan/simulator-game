extends Node2D

@onready var world_container: Node2D = $WorldContainer
@onready var mobile_controls: CanvasLayer = $MobileControls

var current_world: Node2D = null


func _ready() -> void:
	# Load the world from GameManager's saved state
	var world_path = GameManager.current_scene

	# If no current scene set (new game), use default
	if world_path == "":
		world_path = "res://scenes/world/field.tscn"

	_load_world(world_path)

	# Set player reference for mobile controls
	_setup_mobile_controls()


func _load_world(world_path: String) -> void:
	# Clear existing world
	if current_world:
		current_world.queue_free()

	# Load new world
	var world_scene = load(world_path)
	if world_scene:
		current_world = world_scene.instantiate()
		world_container.add_child(current_world)
		print("[Main] Loaded world: ", world_path)
	else:
		print("[Main] ERROR: Failed to load world: ", world_path)


func _setup_mobile_controls() -> void:
	# Wait for player to be ready
	await get_tree().process_frame

	var player = get_tree().get_first_node_in_group("player")
	if player and mobile_controls:
		mobile_controls.set_player(player)
