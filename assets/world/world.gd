class_name World extends Node

signal on_win
signal on_loose

@export var map_size: int = 10;
@export var min_groth_distance: int = 3;

@export var root_decay_rate: float = 0.5
@export var root_groth_rate: float = 2
@export var root_heal_rate: float = 1

@export var root_distance_penalty: float = 0.75
@export var max_root_size: float = 10
@export var min_root_size: float = 3
@export var root_state_count: int = 5

var mushrooms: Dictionary[int, Array]
var roots: Dictionary[int, float]
func _ready():
	Engine.time_scale = 5
	
	for q in range(-map_size - 10, map_size + 10):
		mushrooms[q] = []
		roots[q] = 0
		
	roots[-map_size + 9] = max_root_size * root_distance_penalty
	roots[-map_size + 10] = max_root_size
	roots[-map_size + 11] = max_root_size* root_distance_penalty
	
	roots[map_size - 16] = max_root_size* root_distance_penalty
	roots[map_size - 17] = max_root_size
	roots[map_size - 18] = max_root_size* root_distance_penalty
			
	$Camera2D.slideToPosition($CameraStartPosition.global_position, 1.5)

func get_player_mushrooms(player: Mushroom.Player) -> Array[Mushroom]:
	var res:Array[Mushroom] = []
	for q in $Terrain/Mushrooms.get_children():
		if q is Mushroom and q.player == player:
			res.push_back(q)
	return res
	
func get_cell_position(postion: int) -> float:
	return $Terrain.map_to_local(Vector2i(postion, 0)).x

func get_borrowed_mushroom(position: int) -> Mushroom:
	for q in mushrooms[position]:
		if q.is_borrowed() and !q.is_dead():
			return q
	return null

func is_cell_free(position: int, distance: int) -> bool:
	for d in range(0, distance):
		if get_borrowed_mushroom(position + d):
			return false
		if get_borrowed_mushroom(position - d):
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
		$Terrain/Roots.set_cell(Vector2i(cell_id, 0), tile_id, Vector2i.ZERO, 0)	
	
func grow_mushroom(position: int, delta: float):
	var mushroom = get_borrowed_mushroom(position)
	if mushroom:
		if roots[position]:
			mushroom.receive_heal(delta * root_heal_rate)
		else:			
			mushroom.recieve_damage(delta * root_decay_rate)
	elif is_cell_free(position, min_groth_distance):
		var owner = get_root_owner(position)		
		if roots[position] and owner:
			var spore = owner.get_spore()
			if spore:				
				mushrooms[position].push_back(spore)
				spore.position.x = $Terrain.map_to_local(Vector2i(position, 0)).x
				$Terrain/Mushrooms.add_child(spore)

func get_root_owner(position: int) -> Mushroom:
	var can_left = true
	var can_right = true
	for q in range(0, map_size):
		can_left = can_left and roots[position - q] > min_root_size
		can_right = can_right and roots[position + q] > min_root_size
		if !can_left and !can_right:
			return null
				
		var left = get_borrowed_mushroom(position - q) if can_left else null
		var right = get_borrowed_mushroom(position + q) if can_right else null
		if left and !right:
			return left;
		if !left and right:
			return right;
		if left and right:
			return right if left.player == right.player else null;			
	return null	
	
func get_allowed_size():
	var allowed_root_size: Dictionary[int, float]
	for cell_id in range(-map_size, map_size): 
		var mushroom = get_borrowed_mushroom(cell_id)
		if mushroom && mushroom.is_grown():
			allowed_root_size[cell_id] = max_root_size
		else:
			allowed_root_size[cell_id] = max(roots.get(cell_id - 1, 0), roots.get(cell_id + 1, 0))  * root_distance_penalty
			if allowed_root_size[cell_id] < min_root_size:
				allowed_root_size[cell_id] = 0
	return allowed_root_size

func natual_groth(delta: float):
	var allowed_root_size = get_allowed_size()
	for distance in range(0, map_size): 	
		for direction in [-1, 1] if distance > 0 else [1]:
			var cell_id = distance * direction	
			if roots[cell_id] == allowed_root_size[cell_id]:
				grow_mushroom(cell_id, delta)
			elif roots[cell_id] > allowed_root_size[cell_id]:
				roots[cell_id] = max(allowed_root_size[cell_id], roots[cell_id] - delta * root_decay_rate)	
			else:
				roots[cell_id] = min(allowed_root_size[cell_id], roots[cell_id] + delta * root_groth_rate)

func _physics_process(delta: float):
	rebuild_mushrooms()
	natual_groth(delta)
	apply_root_tiles()
	
func msg(msg: String):
	print("%s: %s" % [Time.get_ticks_msec(), msg])		


func _on_left_mama_on_death() -> void:
	on_win.emit()

func _on_right_mama_on_death() -> void:
	on_loose.emit()
