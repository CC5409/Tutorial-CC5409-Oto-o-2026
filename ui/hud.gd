class_name HUD
extends CanvasLayer

@export var player_coins_scene: PackedScene

@onready var player_coins_container: VBoxContainer = %PlayerCoinsContainer
@onready var health_bar: ProgressBar = %HealthBar
@onready var skill_progress_bar: TextureProgressBar = %SkillProgressBar
@onready var skill_label: Label = %SkillLabel



func _ready() -> void:
	for player_data: Statics.PlayerData in Game.players:
		var player_coins_inst: PlayerCoins = player_coins_scene.instantiate()
		player_coins_container.add_child(player_coins_inst)
		player_coins_inst.set_player_data(player_data)

func set_skill_progress(value: float) -> void:
	skill_label.text = "%.1f" % value
	skill_progress_bar.value = skill_progress_bar.max_value - value
	
	skill_label.visible = value != 0
