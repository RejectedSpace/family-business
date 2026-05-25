extends Node3D

var item: Node3D
var rarity: int

@onready var label: Label = $SubViewport/Label
@onready var items: Node3D = $Items
@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if label.label_settings.get_reference_count() > 1:
		label.label_settings = label.label_settings.duplicate()
	
	determine_rarity()
	
	var rarity_matches: Array = []
	for i in items.get_children():
		if i.rarity == rarity:
			rarity_matches.append(i)
			
	item = rarity_matches.pick_random()
	
	item.visible = true
	animator.play("Spin")
	label_sign()

func label_sign() -> void:
	var item_name = item.name
	item_name = item_name.replace("_", "%")
	label.text = item_name + "\n$" + str(item.price) + "\n" + rarity_tag()
	label.label_settings.font_color = rarity_color()

func determine_rarity() -> void:
	var rarity_roll = randf()
	
	if rarity_roll < 0.50:
		rarity = 0
	elif rarity_roll < 0.83:
		rarity = 1
	elif rarity_roll < 0.95:
		rarity = 2
	else:
		rarity = 3

func rarity_tag() -> String:
	match rarity:
		0: return "Common"
		1: return "Uncommon"
		2: return "Rare"
		3: return "Legendary"
	return "?"

func rarity_color() -> Color:
	match rarity:
		0: return "White"
		1: return "Green"
		2: return "Red"
		3: return "Yellow"
	return "Brown"

func _on_interactable_interacted(interactor: Interactor) -> void:
	if item and Global.cash >= item.price:
		Global.cash -= item.price
		if item is Gun:
			item.clip = item.clip_size
			item.ammo = item.ammo_cappacity
		interactor.player.give_item(item)
		item.visible = false
		item = null
		label.text = "SOLD"
