extends Control

@export var item_card_scene: PackedScene
@export var item_data_array: Array[ItemData]

@onready var item_card_1: ItemCard = %ItemCard1
@onready var item_card_2: ItemCard = %ItemCard2
@onready var item_card_3: ItemCard = %ItemCard3
@onready var item_card_container: HBoxContainer = %ItemCardContainer
@onready var reroll_button: Button = %RerollButton


func _ready() -> void:
	hide()
	generate_cards()
	reroll_button.pressed.connect(generate_cards)
	item_card_1.bought.connect(_on_bought.bind(item_card_1))
	item_card_2.bought.connect(_on_bought.bind(item_card_2))
	item_card_3.bought.connect(_on_bought.bind(item_card_3))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("store"):
		visible = not visible


func generate_cards() -> void:
	if not item_card_scene:
		return
	for item_card: ItemCard in item_card_container.get_children():
		item_card.item_data = Game.items.pick_random()
	
func _on_bought(item_card: ItemCard) -> void:
	item_card.item_data = Game.items.pick_random()
