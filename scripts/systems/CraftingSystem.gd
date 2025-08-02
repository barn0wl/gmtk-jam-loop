extends Node

var recipes := {}

func _ready():
	load_recipes()

func load_recipes():
	for item_id in ItemDatabase.items.keys():
		var item = ItemDatabase.items[item_id]
		if item.has("requires") and item.has("produces"):
			recipes[item_id] = {
				"requires": item["requires"],
				"produces": item["produces"]
			}

func can_craft(recipe_id: String, inventory: Array) -> bool:
	if not recipes.has(recipe_id):
		return false

	var required = recipes[recipe_id]["requires"]
	var inventory_counts = get_inventory_summary(inventory)

	for item_id in required:
		if not ItemDatabase.item_exists(item_id):
			print("Unknown item in recipe: ", item_id)
			return false
		if inventory_counts.get(item_id, 0) < required[item_id]:
			return false
	return true

func craft(recipe_id: String, inventory: Array) -> Array:
	if not can_craft(recipe_id, inventory):
		return []  # crafting failed

	var required = recipes[recipe_id]["requires"]
	var produced = recipes[recipe_id]["produces"]

	# Remove required items
	for item_id in required:
		remove_from_inventory(inventory, item_id, required[item_id])

	var crafted_items := []

	# Add full item entries to return
	for item_id in produced:
		var item_data = ItemDatabase.get_item(item_id)
		crafted_items.append({
			"id": item_id,
			"amount": produced[item_id],
			"data": item_data
		})

	return crafted_items

func get_inventory_summary(inventory: Array) -> Dictionary:
	var summary := {}
	for entry in inventory:
		var id = entry["id"]
		summary[id] = summary.get(id, 0) + entry["amount"]
	return summary

func remove_from_inventory(inventory: Array, item_id: String, amount: int) -> void:
	var to_remove = amount
	for i in range(inventory.size()):
		var entry = inventory[i]
		if entry["id"] == item_id:
			var subtract = min(to_remove, entry["amount"])
			inventory[i]["amount"] -= subtract
			to_remove -= subtract
			if inventory[i]["amount"] <= 0:
				inventory.remove_at(i)
				i -= 1  # adjust index since list shrinks
			if to_remove <= 0:
				return
