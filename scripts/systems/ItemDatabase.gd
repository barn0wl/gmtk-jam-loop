extends Node

var items: Dictionary = {}

func _ready():
	load_items()

func load_items():
	items = {
		"wood": {
			"id": "wood",
			"name": "Wood",
			"type": "resource",
			"description": "Used for crafting.",
			"stackable": true,
			"icon": preload("res://assets/items/0001.png")
		},
		"stone": {
			"id": "stone",
			"name": "Stone",
			"type": "resource",
			"description": "Can be used to craft tools.",
			"stackable": true,
			"icon": preload("res://assets/items/0002.png")
		},
		"spear": {
			"id": "spear",
			"name": "Spear",
			"type": "weapon",
			"description": "Basic melee weapon.",
			"stackable": false,
			"damage": 10,
			"equippable": true,
			"icon": preload("res://assets/items/spear.png")
		},
		"torch": {
			"id": "torch",
			"name": "Torch",
			"type": "tool",
			"description": "Lights your way during night.",
			"stackable": false,
			"light_radius": 120,
			"equippable": true,
			"icon": preload("res://assets/items/torch.png")
		}
	}

func get_item(id: String) -> Dictionary:
	return items.get(id, {})

func item_exists(id: String) -> bool:
	return items.has(id)
