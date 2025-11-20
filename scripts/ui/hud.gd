extends CanvasLayer

# UI Elements
@onready var hp_label: Label = $HUDContainer/StatsPanel/HPLabel
@onready var hp_bar: ProgressBar = $HUDContainer/StatsPanel/HPBar
@onready var level_label: Label = $HUDContainer/StatsPanel/LevelLabel
@onready var xp_bar: ProgressBar = $HUDContainer/StatsPanel/XPBar
@onready var gold_label: Label = $HUDContainer/StatsPanel/GoldLabel


func _ready() -> void:
	# Connect to GameManager signals
	if GameManager:
		GameManager.health_changed.connect(_on_health_changed)
		GameManager.xp_changed.connect(_on_xp_changed)
		GameManager.level_changed.connect(_on_level_changed)
		GameManager.gold_changed.connect(_on_gold_changed)

		# Initialize with current values
		_on_health_changed(GameManager.player_health, GameManager.player_max_health)
		_on_level_changed(GameManager.player_level)
		_on_xp_changed(GameManager.player_xp, _get_xp_for_next_level())
		_on_gold_changed(GameManager.player_gold)


func _on_health_changed(current_hp: int, max_hp: int) -> void:
	if hp_label:
		hp_label.text = "HP: %d / %d" % [current_hp, max_hp]
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp


func _on_level_changed(new_level: int) -> void:
	if level_label:
		level_label.text = "Level: %d" % new_level


func _on_xp_changed(current_xp: int, xp_to_next: int) -> void:
	if xp_bar:
		xp_bar.max_value = xp_to_next
		xp_bar.value = current_xp


func _on_gold_changed(gold: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % gold


func _get_xp_for_next_level() -> int:
	if GameManager.player_level < GameManager.xp_thresholds.size():
		return GameManager.xp_thresholds[GameManager.player_level]
	return 9999
