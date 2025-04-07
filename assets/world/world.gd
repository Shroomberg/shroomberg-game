class_name World extends Node

@export var map_size = 10;
@export var min_mushroom_distance = 3;
@export var max_root_distance = 5;

var max_root_size = 3;
var mushroom_info: Dictionary[int, Mushroom] = {}
var closest_root_mushroom: Dictionary[int, Mushroom] = {}
var closest_borrowed_mushroom: Dictionary[int, Mushroom] = {}

func _ready() -> void:
	pass

func get_closest_free_position(position: float, direction: int) -> float:
	var closest_tile = get_closest_tile(position, direction)
	var global = $Terrain.to_global($Terrain.map_to_local(Vector2i(closest_tile, 0)))
	return global.x

func get_closest_tile(position: float, direction: int) -> int:
	var map_position = $Terrain.local_to_map($Terrain.to_local(Vector2(position, 0)))
	var global = $Terrain.to_global($Terrain.map_to_local(map_position))
	
	if (direction < 0 and position > global.x) or (direction > 0 and position < global.x):
		return find_free_tile(map_position.x, direction)
	return find_free_tile(map_position.x + direction, direction)

func find_free_tile(position: int, direction: int)	-> int:
	while closest_borrowed_mushroom.get(position):
		position += direction
	return position	

func get_root_data(position: int) -> int:
	return $Roots.get_cell_source_id(Vector2i(position, 0))
	
func set_root_data(position: int, data: int):
	$Roots.get_used_cells()
	$Roots.set_cell(Vector2i(position, 0), data, Vector2i.ZERO, 0)	

func is_grown_root(position: int):
	return get_root_data(position) == max_root_size

func get_mushroom(position: int) -> Mushroom:
	return mushroom_info[position]
	
func unborrow_mushroom(mushroom: Mushroom):
	var map_position = $Terrain.local_to_map($Terrain.to_local(mushroom.position))
	mushroom_info[map_position.x] = null
	
func borrow_mushroom(mushroom: Mushroom):
	var map_position = $Terrain.local_to_map($Terrain.to_local(mushroom.position))
	mushroom_info[map_position.x] = mushroom

func grow_root(position: int):	
	var data = get_root_data(position)
	if closest_root_mushroom.get(position):
		set_root_data(position, min(data + 1, max_root_size))
			
func decay_root(position: int):	
	var data = get_root_data(position)
	if !closest_root_mushroom.get(position):
		set_root_data(position, max(data - 1, -1))

func rebuild_closest_root_mushrooms():
	closest_root_mushroom = {}	
	for d in range(0, max_root_distance):
		for q in mushroom_info.keys():
			if d == 0:
				closest_root_mushroom[q] = mushroom_info[q]
			else:
				if is_grown_root(q + d - 1) and !closest_root_mushroom.get(q + d):
					closest_root_mushroom[q + d] = mushroom_info[q]
				if is_grown_root(q - d + 1) and !closest_root_mushroom.get(q - d):
					closest_root_mushroom[q - d] = mushroom_info[q]					
					
func rebuild_closest_borrowed_mushrooms():
	closest_borrowed_mushroom = {}	
	for d in range(0, min_mushroom_distance):
		for q in mushroom_info.keys():
			if d == 0:
				closest_borrowed_mushroom[q] = mushroom_info[q]
			else:
				if !closest_borrowed_mushroom.get(q + d):
					closest_borrowed_mushroom[q + d] = mushroom_info[q]
				if !closest_borrowed_mushroom.get(q - d):
					closest_borrowed_mushroom[q - d] = mushroom_info[q]	

func _on_root_groth_timer_timeout():
	rebuild_closest_root_mushrooms()
	rebuild_closest_borrowed_mushrooms()	
	for q in range(-map_size, map_size):
		grow_root(q)

func _on_root_decay_timer_timeout():
	rebuild_closest_root_mushrooms()
	rebuild_closest_borrowed_mushrooms()	
	for q in range(-map_size, map_size):
		decay_root(q)
	
func msg(msg: String):
	print("%s: %s" % [Time.get_ticks_msec(), msg])		
