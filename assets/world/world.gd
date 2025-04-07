class_name World extends Node

@export var map_size: int = 10;
@export var min_groth_distance: int = 3;
@export var root_decay_rate: float = 0.3
@export var root_groth_rate: float = 3
@export var root_distance_penalty: float = 0.8
@export var max_root_size: float = 10
@export var root_state_count: int = 5

var mushrooms: Dictionary[int, Array]
var roots: Dictionary[int, float]
var root_owners: Dictionary[int, Mushroom]
func _ready():
	for q in range(-map_size, map_size):
		mushrooms[q] = []
		roots[q] = 0
		root_owners[q] = null
	$Camera2D.slideToPosition($CameraStartPosition.global_position, 1.5)

func get_root_data(position: int) -> int:
	return $Roots.get_cell_source_id(Vector2i(position, 0))
	
func get_cell_position(postion: int) -> float:
	return $Terrain.map_to_local(Vector2i(postion, 0)).x

func get_borrowed_mushroom(position: int) -> Mushroom:
	for q in mushrooms[position]:
		if q.is_borrowed():
			return q
	return null

func is_cell_free_to_grow(position: int) -> bool:
	for d in range(0, min_groth_distance):
		if get_borrowed_mushroom(position + d):
			return false
	return true

func rebuild_mushrooms():
	for q in range(-map_size, map_size):
		mushrooms[q].clear()		
	for mushroom in $Terrain/Mushrooms.get_children():
		mushroom.world = self
		mushroom.cell_id = $Terrain.local_to_map(mushroom.position).x
		mushrooms[mushroom.cell_id].push_back(mushroom)

func apply_root_tiles():
	for cell_id in range(-map_size, map_size):
		var tile_id = round(roots[cell_id] * root_state_count / max_root_size) - 2;
		$Roots.set_cell(Vector2i(cell_id, 0), tile_id, Vector2i.ZERO, 0)	
		
func natual_groth(delta: float):
	var allowed_sizes: Dictionary[int, float] 	
	for cell_id in range(-map_size, map_size): 
		var mushroom = get_borrowed_mushroom(cell_id)
		if mushroom:
			allowed_sizes[cell_id] = max_root_size
			root_owners[cell_id] = mushroom
		else:			
			var left = roots.get(cell_id - 1, 0)
			var right = roots.get(cell_id + 1, 0)
			allowed_sizes[cell_id] = floor(max(left, right) * root_distance_penalty)
			if allowed_sizes[cell_id] == 0:
				root_owners[cell_id] = null
			elif left > right:
				root_owners[cell_id] = root_owners[cell_id - 1]
			else:
				root_owners[cell_id] = root_owners[cell_id + 1]		
	
	for cell_id in range(-map_size, map_size): 		
		if roots[cell_id] > allowed_sizes[cell_id]:
			roots[cell_id] = max(allowed_sizes[cell_id], roots[cell_id] - delta * root_decay_rate)	
		else:
			roots[cell_id] = min(allowed_sizes[cell_id], roots[cell_id] + delta * root_groth_rate)

func _physics_process(delta: float):
	rebuild_mushrooms()
	natual_groth(delta)
	apply_root_tiles()
	
func msg(msg: String):
	print("%s: %s" % [Time.get_ticks_msec(), msg])		
