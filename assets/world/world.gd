class_name World extends Node

func get_closest_tile(position: Vector2, direction: float):
	return $Terrain/TileMapLayer.map_to_local(position)
