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

@export var max_size: float = 4
@export var grown_size: float = 2
@export var ungrown_decay_rate: float = 0.1
@export var min_size: float = 1

@export var speed: float = 100.0
 
@export var player: Player = Player.Left
@export var state: UnitState
@export var size: float

var power_factor: float 
var target: Mushroom
var borrow_requested: bool
var direction: int

var world: World
var cell_id: int
				
func _ready() -> void:
	pass				
				
func is_dead() -> bool:
	return state == UnitState.Dead
	
func is_borrowed() -> bool:
	return state in [UnitState.Growing, UnitState.Borrowing, UnitState.Borrowed, UnitState.BorrowedAttacking, UnitState.BorrowedAttackCooldown]
	
func is_grown() -> bool:
	return !is_dead() and state != UnitState.Growing
	
func can_borrow_here() -> bool:	
	var is_near_center = abs(position.x - world.get_cell_position(cell_id)) < 20	
	return is_near_center and world.is_cell_free_to_grow(cell_id)
		
func receive_heal(amount: float):
	set_size(min(max_size, size + amount))
	match state:
		UnitState.Growing:
			if size >= grown_size:
				grow()

func recieve_damage(amount: float):	
	set_size(max(0, size - amount))
	match state:
		UnitState.Growing:
			if size == 0:	
				die()
		_:
			if size < min_size:		
				die()	
					
func _physics_process(delta: float):
	match state:
		UnitState.Moving:
			move(delta)			
		UnitState.Growing:
			recieve_damage(delta * ungrown_decay_rate)

func move(delta: float):	
	position.x += direction * speed * delta * power_factor
	if borrow_requested and can_borrow_here():		
		borrow()

func die():
	pass	
func grow():
	pass
func borrow():
	pass
func set_size(new_size: float):
	pass
