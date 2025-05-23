class_name Mushroom extends CharacterBody2D

signal on_death

enum Player { Left, Right }
enum UnitState {
	NA,
	Growing, 
	Borrowing, Borrowed, Unborrowing, 
	BorrowedAttacking, BorrowedAttackCooldown, 	
	Moving, Attacking, AttackCooldown,
	Dead
}

@export var max_size: float
@export var grown_size: float
@export var ungrown_decay_rate: float = 0.1
@export var min_size: float = 2
@export var borrow_distance: int = 1

@export var speed: float = 100.0
 
@export var player: Player = Player.Left
@export var state: UnitState
@export var size: float
@export var spore_cooldown: float = 5

var power_factor: float 
var target: Mushroom
var borrow_requested: bool
var direction: int

var world: World
var cell_id: int
var current_spore_cooldown = spore_cooldown
				
func _ready() -> void:
	if player == Player.Right:
		modulate = modulate.from_rgba8(255, 190, 190)
	else:
		modulate = modulate.from_rgba8(190, 190, 255)
	pass				
				
func is_dead() -> bool:
	return state == UnitState.Dead or is_queued_for_deletion()
	
func is_borrowed() -> bool:
	return state in [UnitState.Growing, UnitState.Borrowing, UnitState.Borrowed, UnitState.BorrowedAttacking, UnitState.BorrowedAttackCooldown]
	
func is_grown() -> bool:
	return !is_dead() and state != UnitState.Growing
	
func can_borrow_here() -> bool:	
	var is_near_center = abs(position.x - world.get_cell_position(cell_id)) < 20	
	return is_near_center and world.is_cell_free(cell_id, borrow_distance)
		
func receive_heal(amount: float):
	set_size(min(max_size, size + amount))
	match state:
		UnitState.Growing:
			if size >= grown_size:
				grow()

func recieve_damage(amount: float):	
	set_size(max(0, size - amount))
	if state == UnitState.Growing:
		die()
	if size < min_size:		
		die()	
					
func _physics_process(delta: float):
	current_spore_cooldown -= delta
	match state:
		UnitState.Moving:
			move(delta)

func move(delta: float):	
	position.x += direction * speed * delta / power_factor
	if borrow_requested and can_borrow_here():		
		borrow()

func die():
	target = null
	on_death.emit()
	set_state(UnitState.Dead)
	queue_free()
	
func set_size(new_size: float):
	size = new_size
	power_factor = size / max_size
	scale = Vector2(power_factor * direction, power_factor)	

func get_spore() -> Mushroom:
	if current_spore_cooldown > 0:
		return null
	current_spore_cooldown = spore_cooldown
	var spore = self.duplicate()
	spore.size = 0
	return spore	
	
func grow():
	pass
func borrow():
	pass
func set_state(new_state: UnitState):
	pass
