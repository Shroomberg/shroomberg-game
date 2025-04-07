class_name Mushroom extends CharacterBody2D

enum Player { Left, Right }
enum UnitState {
	NA,
	Growing, 
	Borrowing, Borrowed, Unborrowing, 
	BorrowedAttacking, BorrowedAttackCooldown, 	
	Moving, Attacking, AttackCooldown,
	Dead
}

@export var player: Player = Player.Left
@export var state: UnitState
@export var size: float
var world: World
var cell_id: int
				
func _ready() -> void:
	pass				
				
func is_dead() -> bool:
	return state == UnitState.Dead
	
func is_borrowed() -> bool:
	return state == UnitState.Growing or state == UnitState.Borrowing or state == UnitState.Borrowed
	
func is_grown() -> bool:
	return !is_dead() and state != UnitState.Growing
	
func can_borrow_here() -> bool:	
	var is_near_center = abs(position.x - world.get_cell_position(cell_id)) < 20	
	return is_near_center and world.is_cell_free_to_grow(cell_id)
	
func receive_heal(amount: float):
	pass

func recieve_damage(amount: float):	
	pass
