extends Node

var items: Dictionary = {}

func _ready():
	load_items()

func load_items():
	items = {
		"clock": {
			"id": "clock",
			"name": "Clock",
			"type": "consumable",
			"time_bonus": 10.0,
			"stackable": false,
			"icon": preload("res://assets/items/clock.png")
		},
		"key": {
			"id": "key",
			"name": "Key",
			"type": "objective",
			"stackable": false,
			"icon": preload("res://assets/items/key.png")
		},
		"energy_orb": {
			"id": "energy_orb",
			"name": "Energy Orb",
			"type": "powerup",
			"energy_bonus": 1,
			"stackable": false,
			"icon": preload("res://assets/items/energy_orb.png")
		}
	}

func get_item(id: String) -> Dictionary:
	return items.get(id, {})

func item_exists(id: String) -> bool:
	return items.has(id)
