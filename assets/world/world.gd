class_name World extends Node

@export var map_size: int = 10;
@export var min_groth_distance: int = 3;
@export var max_root_distance: int = 5;
@export var root_decay_rate: float = 1
@export var root_groth_rate: float = 3
@export var max_root_size: float = 10
@export var root_state_count: int = 4

var closest_root_mushroom: Dictionary[int, Mushroom] = {}
var closest_borrowed_mushroom: Dictionary[int, Mushroom] = {}

var mushrooms: Dictionary[int, Array]
var roots: Dictionary[int, float]
var root_distance_to_mushroom: Dictionary[int, int]
func _ready():
	for q in range(-map_size, map_size):
		mushrooms[q] = []
		roots[q] = 0
	$Camera2D.slideToPosition($CameraStartPosition.global_position, 1.5)

func get_root_data(position: int) -> int:
	return $Roots.get_cell_source_id(Vector2i(position, 0))
	
func is_grown_root(position: int):
	return get_root_data(position) == max_root_size

func get_cell_position(postion: int) -> float:
	return $Terrain.map_to_local(Vector2i(postion, 0)).x

func get_borrowed_mushroom(position: int) -> Mushroom:
	return mushrooms[position].filter(func(q: Mushroom): return q.is_borrowed()).front()

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
		
func rebuild_root_distance():
	for q in range(-map_size, map_size):
		root_distance_to_mushroom[q] = -1

func apply_root_tiles():
	for cell_id in range(-map_size, map_size):
		var tile_id = round(roots[cell_id] * root_state_count / max_root_size) - 1;
		$Roots.set_cell(Vector2i(cell_id, 0), tile_id, Vector2i.ZERO, 0)	

func natural_decay(delta: float):
	for cell_id in range(-map_size, map_size):
		roots[cell_id] = max(0, roots[cell_id] - delta * root_decay_rate)		
		
func natual_groth(delta: float):
	for cell_id in range(-map_size, map_size): 
		var mushroom = get_borrowed_mushroom(cell_id)
		if mushroom:
			roots[cell_id] = min(max_root_size, roots[cell_id] + delta * root_groth_rate)

func _physics_process(delta: float):
	rebuild_mushrooms()	
	natural_decay(delta)
	natual_groth(delta)
	apply_root_tiles()

#func rebuild_closest_root_mushrooms():
	#closest_root_mushroom = {}	
	#for d in range(0, max_root_distance):
		#for q in mushroom_info.keys():
			#if d == 0:
				#closest_root_mushroom[q] = mushroom_info[q]
			#else:
				#if is_grown_root(q + d - 1) and !closest_root_mushroom.get(q + d):
					#closest_root_mushroom[q + d] = mushroom_info[q]
				#if is_grown_root(q - d + 1) and !closest_root_mushroom.get(q - d):
					#closest_root_mushroom[q - d] = mushroom_info[q]					
					#
	#for d in range(0, min_mushroom_distance):
		#for q in mushroom_info.keys():
			#if d == 0:
				#closest_borrowed_mushroom[q] = mushroom_info[q]
			#else:
				#if !closest_borrowed_mushroom.get(q + d):
					#closest_borrowed_mushroom[q + d] = mushroom_info[q]
				#if !closest_borrowed_mushroom.get(q - d):
					#closest_borrowed_mushroom[q - d] = mushroom_info[q]	
	
func msg(msg: String):
	print("%s: %s" % [Time.get_ticks_msec(), msg])		
