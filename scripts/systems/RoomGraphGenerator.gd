extends Node

class_name RoomGraphGenerator

@export var max_rooms: int = 10
@export var allow_backtracking := false  # pour exploration plus linéaire ou plus ouverte

var directions := {
	"up": Vector2i(0, -1),
	"down": Vector2i(0, 1),
	"left": Vector2i(-1, 0),
	"right": Vector2i(1, 0)
}

func generate_graph(start: Vector2i = Vector2i.ZERO, room_limit: int = 10) -> Dictionary:
	var graph := {}
	graph[start] = {"connected": []}
	var frontier := [start]

	while graph.size() < room_limit and not frontier.is_empty():
		var current = frontier.pop_front()
		var available_dirs := directions.values().duplicate()
		available_dirs.shuffle()

		for dir in available_dirs:
			var neighbor = current + dir

			if graph.has(neighbor):
				if allow_backtracking and not neighbor in graph[current]["connected"]:
					graph[current]["connected"].append(neighbor)
					graph[neighbor]["connected"].append(current)
				continue

			# Prevent over-expansion
			if graph.size() >= room_limit:
				break

			# Add the new room
			graph[neighbor] = {"connected": [current]}
			graph[current]["connected"].append(neighbor)
			frontier.append(neighbor)

	return graph
