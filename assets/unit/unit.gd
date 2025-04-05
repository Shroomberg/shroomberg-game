class_name Unit extends Node2D

signal unit_died();

enum UnitAction { Idle, Moving, Attacking }

const WALK_SPEED = 200.0

@export var max_hp: float = 10
@export var max_speed: float = 100.0
@export var damage: float = 1.0
@export var vision_range: float = 100.0
@export var direction = 1

var hp: float = 10

var action: UnitAction = UnitAction.Idle
var target: Unit = null

var action_handlers = {
	UnitAction.Idle: process_idle,
	UnitAction.Moving: process_moving,
	UnitAction.Attacking: process_attacking
}

func _physics_process(delta: float) -> void:
	action_handlers[action].call(delta)	

func _ready():
	hp = max_hp
	$VisionArea/Shape.scale = Vector2(vision_range, vision_range)
	set_action(UnitAction.Moving)
	$Sprite2D.scale = Vector2(direction, 1)
	
func set_action(new_action: UnitAction):
	action = new_action
	print(UnitAction.keys()[action])
	$Animation.play(UnitAction.keys()[action])
	
func process_idle(delta: float):
	pass
	
func process_moving(delta: float):		
	position.x += direction * WALK_SPEED * delta;		
	
func process_attacking(delta: float):
	target.take_damage(damage)
	if target.is_dead():
		scan_for_targets()

func is_dead():
	return hp <= 0 or is_queued_for_deletion() 

func take_damage(amount: int):
	hp -= amount
	$HealthBar.value = hp/max_hp
	if hp <= 0:
		kill()	

func kill() -> void:	
	unit_died.emit()
	queue_free()

func can_use_target(node: Node2D) -> bool:
	return node != self and node is Unit and !node.is_dead()

func set_target(node: Node2D):
	target = node
	set_action(UnitAction.Attacking)

func scan_for_targets():
	print('scanning for targets')	
	target = null
	for node in $VisionArea.get_overlapping_bodies():
		if can_use_target(node):
			set_target(node)
	if !target:
		set_action(UnitAction.Moving)

func _on_body_entered(node: Node2D):
	if !target && can_use_target(node):
		set_target(node)
