extends Control

@onready var screen: Panel = %Screen
@onready var player_box_container: VBoxContainer = %PlayerBoxContainer
@onready var player_container: VBoxContainer = %PlayerContainer
@onready var pause_label: Label = %PauseLabel


func _ready() -> void:
	screen.hide()
	player_box_container.hide()
	Game.vote_updated.connect(_on_vote_updated)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Game.set_current_player_vote(not Game.get_current_player().vote)

func _on_vote_updated(id: int) -> void:
	if not get_tree().paused:
		for child in player_container.get_children():
			child.queue_free()
		
		var all_voted: bool = true
		var any_voted: bool = false
		for player_data: Statics.PlayerData in Game.players:
			if player_data.vote:
				any_voted = true
				var player_label = Label.new()
				player_label.text = Game.get_player(id).name
				player_container.add_child(player_label)
			else:
				all_voted = false
		
		player_box_container.visible = any_voted
		pause_label.text = "Paused?"
		
		
		
		if all_voted:
			pause_label.text = "Unpaused?"
			get_tree().paused = true
			screen.show()
			for child in player_container.get_children():
				child.queue_free()
	else:
		
		var none_voted: bool = true
		for player_data: Statics.PlayerData in Game.players:
			if player_data.vote:
				none_voted = false
			else:
				var player_label: Label = Label.new()
				player_label.text = Game.get_player(id).name
				player_container.add_child(player_label)
		if none_voted:
			get_tree().paused = false
			screen.hide()
			player_box_container.hide()
