class_name AI extends Node

@export var world: World

var rng = RandomNumberGenerator.new()

func _on_timer_timeout() -> void:
	var my_units = world.get_player_mushrooms(Mushroom.Player.Right)
	var spitters = my_units.filter(func(q): return q is Spitter)
	var tentaclers = my_units.filter(func(q): return q is Tentacler)
	var mama = my_units.filter(func(q): return q is MamaMushroom).front()
	
	var random = ceil(rng.randf_range(0, spitters.size() / 4))
	for q in range(0, random):
		move_spitter(spitters.pick_random())
	
	random = ceil(rng.randf_range(0, tentaclers.size() / 4))
	for q in range(0, random):
		move_tentacler(tentaclers.pick_random())
	
	if rng.randf_range(0, 1) < 0.01:
		move_mama(mama)
		
func move_spitter(unit: Mushroom):	
	if unit.is_dead():
		return
	if unit.state == Mushroom.UnitState.Borrowed:
		unit.unborrow()
	else:
		unit.borrow_requested = true		
				
func move_tentacler(unit: Mushroom):	
	if unit.is_dead():
		return
	if unit.state == Mushroom.UnitState.Borrowed:
		unit.unborrow()
	else:
		unit.borrow_requested = true	
			
func move_mama(unit: Mushroom):	
	if unit.is_dead():
		return
	if unit.state == Mushroom.UnitState.Borrowed:
		unit.unborrow()
	else:
		unit.borrow_requested = true
		
