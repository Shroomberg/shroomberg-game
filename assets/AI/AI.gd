class_name AI extends Node

@export var world: World

var rng = RandomNumberGenerator.new()
func _on_timer_timeout() -> void:
	var my_units = world.get_player_mushrooms(1)
	if my_units.size() < 5:
		return
	var move_random_units = round(rng.randf_range(0, my_units.size() / 3))
	while move_random_units > 0:
		move_random_units -= 1
		var unit = my_units.pick_random()
		if unit.is_dead():
			continue
		if unit.state == Mushroom.UnitState.Borrowed:
			unit.unborrow()
		else:
			unit.borrow_requested = true
	pass # Replace with function body.
