class_name Roots extends TileMapLayer

func get_closest_tile(position: float, direction: float):
	var map_position = local_to_map(to_local(Vector2(position, 0)))
	var global = to_global(map_to_local(map_position))
	
	if direction < 0:
		if position > global.x:
			return global.x
		map_position.x -= 1
		global = to_global(map_to_local(map_position))
		return global.x
	
	if position < global.x:
		return global.x
	map_position.x += 1
	global = to_global(map_to_local(map_position))
	return global.x

func spawn_root(position: float):
	var map_position = local_to_map(to_local(Vector2(position, 0)))
	set_cell(Vector2i(map_position.x, 0), 2)	
	
