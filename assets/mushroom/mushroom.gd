class_name Mushroom extends CharacterBody2D

enum UnitState {
	NA,
	Growing, 
	Borrowing, Borrowed, Unborrowing, 
	BorrowedAttacking, BorrowedAttackCooldown, 	
	Moving, Attacking, AttackCooldown,
	Dead
}
	
enum Player { Left, Right }

@export var player: Player = Player.Left
@export var max_size: float = 8
@export var grown_size: float = 2
@export var speed: float = 100.0
@export var damage: float = 1.0
@export var action_range: float = 10
@export var borrow_duration: float = 1
@export var attack_duration: float = 1
@export var attack_cooldown: float = 1

const BULLET_SCENE = preload("res://assets/bullet/bullet.tscn")

var state: UnitState
var size: float
var power_factor: float 
var target: Mushroom
var direction: float

func _ready():
	$VisionArea/Shape.scale = Vector2(action_range, action_range)
	if player == Player.Right:
		direction = -1
	else:		
		direction = 1
	set_size(1)
	set_state(UnitState.Growing)	

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is not InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT or !event.pressed:
		return	
	match state:
		UnitState.Borrowed:	
			unborrow()		
		UnitState.Moving:	
			borrow()				

func _on_state_timer_timeout():
	msg("timer")
	match state:
		UnitState.Unborrowing:
			set_state(UnitState.Moving)
		UnitState.Borrowing:
			set_state(UnitState.Borrowed)
		UnitState.Attacking, UnitState.BorrowedAttacking:
			do_target_attack()
		UnitState.AttackCooldown:
			set_state(UnitState.Moving)			
		UnitState.BorrowedAttackCooldown:
			set_state(UnitState.Borrowed)	
		_:
			decide_new_action()

func _on_sprite_animation_finished():	
	match state:
		UnitState.Attacking, UnitState.BorrowedAttacking:
			cooldown_target_attack()

func _on_vision_area_body_exited(body: Node2D) -> void:
	if target == body:
		target = null

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body != self:		
		decide_new_action()
	
func _physics_process(delta: float):
	match state:
		UnitState.Moving:
			move(delta)			
		UnitState.Growing, UnitState.Borrowed:
			receive_heal(delta*0.3)

func set_state(new_state: UnitState):	
	if new_state == state:
		return
	state = new_state
	msg("new state")
	$Sprite.play(UnitState.keys()[new_state])	
	$HealthBar.visible = new_state != UnitState.Dead
	decide_new_action()

func borrow():
	$StateTimer.start(borrow_duration)
	set_state(UnitState.Borrowing)	
	
func unborrow():
	$StateTimer.start(borrow_duration)
	set_state(UnitState.Unborrowing)	
	
func start_target_attack():
	match state:
		UnitState.Borrowed:
			$StateTimer.start(attack_duration)	
			set_state(UnitState.BorrowedAttacking)
		UnitState.Moving:
			$StateTimer.start(attack_duration)	
			set_state(UnitState.Attacking)	

func cooldown_target_attack():
	match state:
		UnitState.Attacking:
			$StateTimer.start(attack_cooldown)	
			set_state(UnitState.AttackCooldown)
		UnitState.BorrowedAttacking:
			$StateTimer.start(attack_cooldown)	
			set_state(UnitState.BorrowedAttackCooldown)	

func do_target_attack():
	if !target:
		return
	var bullet = BULLET_SCENE.instantiate()
	bullet.position = $BulletSpawnPoint.global_position
	bullet.target = target
	bullet.damage = damage
	get_parent().add_child(bullet)
	#target.recieve_damage(damage)	

func move(delta: float):	
	position.x += direction * speed * delta
	
func grow():
	set_state(UnitState.Borrowed)

func set_size(new_size: float):
	size = new_size
	power_factor = sqrt(size / max_size)
	scale = Vector2(power_factor * direction, power_factor)
	$HealthBar.value = size/max_size
	
func receive_heal(amount: float):
	set_size(min(max_size, size + amount))
	match state:
		UnitState.Growing:
			if size >= grown_size:
				grow()

func recieve_damage(amount: float):	
	set_size(max(0, size - amount))
	#if size == 0:	
		#die()
	match state:
		UnitState.Growing:
			if size == 0:	
				die()
		_:
			if size < grown_size:	
				set_state(UnitState.Growing)

func die():
	target = null
	set_state(UnitState.Dead)

func decide_new_action():	
	match state:
		UnitState.Borrowed, UnitState.Moving:
			if !can_use_target(target):
				target = scan_for_target()
			if target:
				msg("target focused")
				start_target_attack()

func can_use_target(unit: Mushroom) -> bool:
	return unit != null and \
		unit.player != player and \
		unit.state != UnitState.Dead
	
func scan_for_target() -> Mushroom:
	msg("scanning for targets")
	for node in $VisionArea.get_overlapping_bodies():
		if can_use_target(node):
			return node
	return null
	
func get_bullet_hit_point():
	return $BulletHitPoint.global_position
	
func is_borrowed():
	return state == UnitState.Borrowed or state == UnitState.BorrowedAttacking or state == UnitState.BorrowedAttackCooldown
	
func msg(msg: String):
	print("%s:%s	%s	%s	%s " % [Time.get_ticks_msec(), get_instance_id(), Player.keys()[player], UnitState.keys()[state], msg])		
